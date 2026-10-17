import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:rahmani_project/features/chat/domain/repositories/chat_repository.dart';

class StartConversation {
  const StartConversation(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, String>> call(String boothId) {
    if (boothId.isEmpty) {
      return Future.value(const Left(ValidationFailure('فروشگاه نامعتبر است.')));
    }
    return _repository.startConversation(boothId);
  }
}

class SendMessage {
  const SendMessage(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, String>> call({
    required String conversationId,
    required String content,
  }) {
    final error = validateMessageContent(content);
    if (error != null) {
      return Future.value(Left(ValidationFailure(error)));
    }
    if (conversationId.isEmpty) {
      return Future.value(const Left(ValidationFailure('گفتگو نامعتبر است.')));
    }
    return _repository.sendMessage(
      conversationId: conversationId,
      content: content.trim(),
    );
  }
}

class GetConversations {
  const GetConversations(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, List<ConversationEntity>>> call() => _repository.getConversations();
}

class GetMessages {
  const GetMessages(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, List<MessageEntity>>> call(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  }) {
    if (conversationId.isEmpty) {
      return Future.value(const Left(ValidationFailure('گفتگو نامعتبر است.')));
    }
    return _repository.getMessages(
      conversationId,
      limit: limit,
      beforeCreatedAt: beforeCreatedAt,
    );
  }
}

class MarkMessagesAsRead {
  const MarkMessagesAsRead(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, void>> call(String conversationId) {
    if (conversationId.isEmpty) {
      return Future.value(const Left(ValidationFailure('گفتگو نامعتبر است.')));
    }
    return _repository.markMessagesRead(conversationId);
  }
}
