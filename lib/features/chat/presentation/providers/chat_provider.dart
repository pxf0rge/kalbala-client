import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:rahmani_project/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:rahmani_project/features/chat/domain/repositories/chat_repository.dart';
import 'package:rahmani_project/features/chat/domain/usecases/chat_usecases.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ChatRemoteDataSourceImpl(SupabaseConfig.client);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remote = ref.watch(chatRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredChatRepository();
  return ChatRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final startConversationProvider =
    Provider((ref) => StartConversation(ref.watch(chatRepositoryProvider)));

final sendMessageProvider = Provider((ref) => SendMessage(ref.watch(chatRepositoryProvider)));

final getConversationsProvider =
    Provider((ref) => GetConversations(ref.watch(chatRepositoryProvider)));

final getMessagesProvider = Provider((ref) => GetMessages(ref.watch(chatRepositoryProvider)));

final markMessagesAsReadProvider =
    Provider((ref) => MarkMessagesAsRead(ref.watch(chatRepositoryProvider)));

final conversationsProvider = FutureProvider<List<ConversationEntity>>((ref) async {
  final result = await ref.read(getConversationsProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (conversations) => conversations,
  );
});

final totalUnreadCountProvider = Provider<int>((ref) {
  final conversations = ref.watch(conversationsProvider).valueOrNull ?? [];
  return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
});

class ChatMessagesState {
  const ChatMessagesState({
    required this.messages,
    this.isSending = false,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<MessageEntity> messages;
  final bool isSending;
  final bool hasMore;
  final bool isLoadingMore;

  ChatMessagesState copyWith({
    List<MessageEntity>? messages,
    bool? isSending,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ChatMessagesNotifier extends AutoDisposeFamilyNotifier<AsyncValue<ChatMessagesState>, String> {
  StreamSubscription<MessageEntity>? _subscription;

  @override
  AsyncValue<ChatMessagesState> build(String conversationId) {
    ref.onDispose(() => _subscription?.cancel());
    _load(conversationId);
    return const AsyncValue.loading();
  }

  Future<void> _load(String conversationId) async {
    final result = await ref.read(getMessagesProvider).call(conversationId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (messages) {
        state = AsyncValue.data(
          ChatMessagesState(
            messages: messages,
            hasMore: hasMoreItems(
              fetchedCount: messages.length,
              pageSize: PaginationConstants.chatMessagePageSize,
            ),
          ),
        );
        _subscribe(conversationId);
        _markRead(conversationId);
      },
    );
  }

  Future<void> loadOlder() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    if (current.messages.isEmpty) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    final oldest = current.messages.first;
    final result = await ref.read(getMessagesProvider).call(
          arg,
          beforeCreatedAt: oldest.createdAt,
        );

    result.fold(
      (failure) => state = AsyncValue.data(current.copyWith(isLoadingMore: false)),
      (olderMessages) {
        final existingIds = current.messages.map((m) => m.id).toSet();
        final uniqueOlder =
            olderMessages.where((message) => !existingIds.contains(message.id)).toList();
        final merged = [...uniqueOlder, ...current.messages]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        state = AsyncValue.data(
          current.copyWith(
            messages: merged,
            hasMore: hasMoreItems(
              fetchedCount: olderMessages.length,
              pageSize: PaginationConstants.chatMessagePageSize,
            ),
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  void _subscribe(String conversationId) {
    _subscription?.cancel();
    _subscription = ref.read(chatRepositoryProvider).watchMessages(conversationId).listen(
      (incoming) {
        final current = state.valueOrNull;
        if (current == null) return;

        final existingIndex = current.messages.indexWhere((m) => m.id == incoming.id);
        final updatedMessages = List<MessageEntity>.from(current.messages);
        if (existingIndex >= 0) {
          updatedMessages[existingIndex] = incoming;
        } else {
          updatedMessages.add(incoming);
          updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _markRead(conversationId);
        }

        state = AsyncValue.data(current.copyWith(messages: updatedMessages));
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> _markRead(String conversationId) async {
    await ref.read(markMessagesAsReadProvider).call(conversationId);
    ref.invalidate(conversationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
    ref.invalidate(notificationsProvider);
  }

  Future<bool> sendMessage(String content) async {
    final conversationId = arg;
    final current = state.valueOrNull;
    if (current == null) return false;

    state = AsyncValue.data(current.copyWith(isSending: true));

    final result = await ref.read(sendMessageProvider).call(
          conversationId: conversationId,
          content: content,
        );

    return result.fold(
      (failure) {
        state = AsyncValue.data(current.copyWith(isSending: false));
        return false;
      },
      (_) {
        state = AsyncValue.data(current.copyWith(isSending: false));
        ref.invalidate(conversationsProvider);
        return true;
      },
    );
  }

  Future<void> refresh() async => _load(arg);
}

final chatMessagesProvider =
    AutoDisposeNotifierProviderFamily<ChatMessagesNotifier, AsyncValue<ChatMessagesState>, String>(
  ChatMessagesNotifier.new,
);

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.user.id;
});
