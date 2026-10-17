import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/support/data/datasources/support_remote_datasource.dart';
import 'package:rahmani_project/features/support/data/models/support_models.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/domain/repositories/support_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({
    required SupportRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final SupportRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, CreateTicketResult>> createTicket(CreateTicketInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());

      final validationError = validateCreateTicketInput(input);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      final data = await _remote.createTicket(
        subject: input.subject.trim(),
        content: input.content.trim(),
        attachmentPath: input.attachmentPath,
      );
      return Right(SupportModels.createResultFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> getMyTickets() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchMyTickets();
      return Right(
        rows
            .map((row) => SupportModels.ticketFromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String ticketId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchTicketDetail(ticketId);
      return Right(SupportModels.detailFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> sendTicketMessage(SendTicketMessageInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());

      final validationError = validateTicketMessageContent(input.content);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      final messageId = await _remote.postTicketMessage(
        ticketId: input.ticketId,
        content: input.content.trim(),
        attachmentPath: input.attachmentPath,
      );
      return Right(messageId);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAttachment({
    required String userId,
    required String ticketId,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final path = await _remote.uploadAttachment(
        userId: userId,
        ticketId: ticketId,
        bytes: bytes,
        fileExtension: fileExtension,
      );
      return Right(path);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> setMessageAttachment({
    required String messageId,
    required String attachmentPath,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.attachMessageFile(
        messageId: messageId,
        attachmentPath: attachmentPath,
      );
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> getSignedAttachmentUrl(String attachmentPath) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final url = await _remote.createSignedAttachmentUrl(attachmentPath);
      return Right(url);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredSupportRepository implements SupportRepository {
  const UnconfiguredSupportRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, CreateTicketResult>> createTicket(CreateTicketInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> getMyTickets() async => const Right([]);

  @override
  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String ticketId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> sendTicketMessage(SendTicketMessageInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> uploadAttachment({
    required String userId,
    required String ticketId,
    required List<int> bytes,
    required String fileExtension,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> setMessageAttachment({
    required String messageId,
    required String attachmentPath,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> getSignedAttachmentUrl(String attachmentPath) async =>
      const Left(AuthFailure(_message));
}
