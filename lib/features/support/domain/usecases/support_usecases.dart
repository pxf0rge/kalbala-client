import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/domain/repositories/support_repository.dart';

final class CreateTicket {
  const CreateTicket(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, CreateTicketResult>> call(CreateTicketInput input) =>
      _repository.createTicket(input);
}

final class GetMyTickets {
  const GetMyTickets(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, List<SupportTicketEntity>>> call() =>
      _repository.getMyTickets();
}

final class GetTicketDetail {
  const GetTicketDetail(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, TicketDetailEntity>> call(String ticketId) =>
      _repository.getTicketDetail(ticketId);
}

final class SendTicketMessage {
  const SendTicketMessage(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, String>> call(SendTicketMessageInput input) =>
      _repository.sendTicketMessage(input);
}
