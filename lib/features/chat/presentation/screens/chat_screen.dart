import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:rahmani_project/features/chat/presentation/providers/chat_provider.dart';
import 'package:rahmani_project/features/chat/presentation/widgets/chat_input.dart';
import 'package:rahmani_project/features/chat/presentation/widgets/message_bubble.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_action.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Real-time chat screen for a single conversation.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.conversationId,
    this.title,
    super.key,
  });

  final String conversationId;
  final String? title;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= PaginationConstants.loadMoreScrollThreshold) {
      ref.read(chatMessagesProvider(widget.conversationId).notifier).loadOlder();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.conversationId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final conversations = ref.watch(conversationsProvider).valueOrNull ?? [];
    ConversationEntity? conversation;
    for (final item in conversations) {
      if (item.id == widget.conversationId) {
        conversation = item;
        break;
      }
    }
    final title = widget.title ?? conversation?.otherPartyName ?? 'گفتگو';
    final boothName = conversation?.boothName;
    final otherUserId = conversation == null || currentUserId == null
        ? null
        : (currentUserId == conversation.buyerId
            ? conversation.sellerId
            : conversation.buyerId);

    ref.listen(chatMessagesProvider(widget.conversationId), (previous, next) {
      final previousCount = previous?.valueOrNull?.messages.length ?? 0;
      final nextCount = next.valueOrNull?.messages.length ?? 0;
      if (nextCount > previousCount && !(next.valueOrNull?.isLoadingMore ?? false)) {
        _scrollToBottom();
      }
    });

    final initial = title.isNotEmpty ? title.characters.first : '?';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (boothName != null && boothName.isNotEmpty && boothName != title)
                    Text(
                      boothName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (otherUserId != null)
            ReportIconButton(
              target: ReportTarget(
                type: ReportTargetType.user,
                targetId: otherUserId,
                label: conversation?.otherPartyName ?? 'کاربر',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری پیام‌ها...'),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref
                    .read(chatMessagesProvider(widget.conversationId).notifier)
                    .refresh(),
              ),
              data: (state) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'هنوز پیامی نیست',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'اولین پیام را برای شروع گفتگو ارسال کنید.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  key: const Key('chat_message_list'),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isLoadingMore && index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final messageIndex = state.isLoadingMore ? index - 1 : index;
                    final message = state.messages[messageIndex];
                    final isMine = currentUserId != null &&
                        isMessageFromCurrentUser(
                          senderId: message.senderId,
                          currentUserId: currentUserId,
                        );
                    return MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
            ),
          ),
          messagesAsync.maybeWhen(
            data: (state) => ChatInput(
              isSending: state.isSending,
              onSend: (content) async {
                final success = await ref
                    .read(chatMessagesProvider(widget.conversationId).notifier)
                    .sendMessage(content);
                if (!context.mounted) return false;
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ارسال پیام ناموفق بود')),
                  );
                }
                return success;
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
