import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, String>> startConversation(String boothId);

  Future<Either<Failure, String>> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  });

  Future<Either<Failure, void>> markMessagesRead(String conversationId);

  Stream<MessageEntity> watchMessages(String conversationId);
}
