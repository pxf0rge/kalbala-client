import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:rahmani_project/features/chat/data/models/chat_models.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:rahmani_project/features/chat/domain/repositories/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ChatRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, String>> startConversation(String boothId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final id = await _remote.createConversation(boothId);
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final id = await _remote.postMessage(conversationId: conversationId, content: content);
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchConversations();
      return Right(
        rows
            .map((row) => ChatModels.conversationFromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchMessages(
        conversationId,
        limit: limit,
        beforeCreatedAt: beforeCreatedAt,
      );
      return Right(
        rows.map((row) => ChatModels.messageFromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesRead(String conversationId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.markRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<MessageEntity> watchMessages(String conversationId) {
    return _remote.subscribeToMessages(conversationId);
  }
}

final class UnconfiguredChatRepository implements ChatRepository {
  const UnconfiguredChatRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, String>> startConversation(String boothId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> sendMessage({
    required String conversationId,
    required String content,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> markMessagesRead(String conversationId) async =>
      const Left(AuthFailure(_message));

  @override
  Stream<MessageEntity> watchMessages(String conversationId) => const Stream.empty();
}
