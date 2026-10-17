import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';

abstract interface class SupportRepository {
  Future<Either<Failure, CreateTicketResult>> createTicket(CreateTicketInput input);

  Future<Either<Failure, List<SupportTicketEntity>>> getMyTickets();

  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String ticketId);

  Future<Either<Failure, String>> sendTicketMessage(SendTicketMessageInput input);

  Future<Either<Failure, String>> uploadAttachment({
    required String userId,
    required String ticketId,
    required List<int> bytes,
    required String fileExtension,
  });

  Future<Either<Failure, void>> setMessageAttachment({
    required String messageId,
    required String attachmentPath,
  });

  Future<Either<Failure, String>> getSignedAttachmentUrl(String attachmentPath);
}
