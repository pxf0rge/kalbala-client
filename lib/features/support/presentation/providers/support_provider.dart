import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/support/data/datasources/support_remote_datasource.dart';
import 'package:rahmani_project/features/support/data/repositories/support_repository_impl.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/domain/repositories/support_repository.dart';
import 'package:rahmani_project/features/support/domain/usecases/support_usecases.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return SupportRemoteDataSourceImpl(SupabaseConfig.client);
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remote = ref.watch(supportRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredSupportRepository();
  return SupportRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final createTicketProvider =
    Provider((ref) => CreateTicket(ref.watch(supportRepositoryProvider)));

final getMyTicketsProvider =
    Provider((ref) => GetMyTickets(ref.watch(supportRepositoryProvider)));

final getTicketDetailProvider =
    Provider((ref) => GetTicketDetail(ref.watch(supportRepositoryProvider)));

final sendTicketMessageProvider =
    Provider((ref) => SendTicketMessage(ref.watch(supportRepositoryProvider)));

final myTicketsProvider = FutureProvider<List<SupportTicketEntity>>((ref) async {
  final result = await ref.read(getMyTicketsProvider).call();
  return result.fold((_) => [], (tickets) => tickets);
});

final ticketDetailProvider =
    FutureProvider.family<TicketDetailEntity, String>((ref, ticketId) async {
  final result = await ref.read(getTicketDetailProvider).call(ticketId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (detail) => detail,
  );
});

final signedAttachmentUrlProvider =
    FutureProvider.family<String, String>((ref, attachmentPath) async {
  final result =
      await ref.read(supportRepositoryProvider).getSignedAttachmentUrl(attachmentPath);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (url) => url,
  );
});
