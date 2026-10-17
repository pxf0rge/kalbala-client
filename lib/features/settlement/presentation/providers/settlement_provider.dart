import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/settlement/data/datasources/settlement_remote_datasource.dart';
import 'package:rahmani_project/features/settlement/data/repositories/settlement_repository_impl.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/domain/repositories/settlement_repository.dart';
import 'package:rahmani_project/features/settlement/domain/usecases/settlement_usecases.dart';

final settlementRemoteDataSourceProvider = Provider<SettlementRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return SettlementRemoteDataSourceImpl(SupabaseConfig.client);
});

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  final remote = ref.watch(settlementRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredSettlementRepository();
  return SettlementRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getSellerBalanceProvider =
    Provider((ref) => GetSellerBalance(ref.watch(settlementRepositoryProvider)));

final getBankAccountsProvider =
    Provider((ref) => GetBankAccounts(ref.watch(settlementRepositoryProvider)));

final addBankAccountProvider =
    Provider((ref) => AddBankAccount(ref.watch(settlementRepositoryProvider)));

final deleteBankAccountProvider =
    Provider((ref) => DeleteBankAccount(ref.watch(settlementRepositoryProvider)));

final requestSettlementProvider =
    Provider((ref) => RequestSettlement(ref.watch(settlementRepositoryProvider)));

final getSettlementHistoryProvider =
    Provider((ref) => GetSettlementHistory(ref.watch(settlementRepositoryProvider)));

final sellerBalanceProvider = FutureProvider<SellerBalanceEntity>((ref) async {
  final result = await ref.read(getSellerBalanceProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (balance) => balance,
  );
});

final bankAccountsProvider = FutureProvider<List<BankAccountEntity>>((ref) async {
  final result = await ref.read(getBankAccountsProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (accounts) => accounts,
  );
});

final settlementsProvider = FutureProvider<List<SettlementEntity>>((ref) async {
  final result = await ref.read(getSettlementHistoryProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (settlements) => settlements,
  );
});
