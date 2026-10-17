import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/settlement/data/datasources/settlement_remote_datasource.dart';
import 'package:rahmani_project/features/settlement/data/models/settlement_models.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/domain/repositories/settlement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SettlementRepositoryImpl implements SettlementRepository {
  SettlementRepositoryImpl({
    required SettlementRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final SettlementRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, SellerBalanceEntity>> getBalance() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchBalance();
      return Right(SettlementModels.balanceFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchBankAccounts();
      return Right(
        rows
            .map((row) => SettlementModels.bankAccountFromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> addBankAccount(AddBankAccountInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final id = await _remote.createBankAccount(
        bankName: input.bankName.trim(),
        accountNumber: input.accountNumber.trim(),
        accountHolder: input.accountHolder.trim(),
      );
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBankAccount(String bankAccountId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.removeBankAccount(bankAccountId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> requestSettlement(RequestSettlementInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final id = await _remote.createSettlementRequest(
        amount: input.amount,
        bankAccountId: input.bankAccountId,
      );
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SettlementEntity>>> getSettlements() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchSettlements();
      return Right(
        rows
            .map((row) => SettlementModels.settlementFromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredSettlementRepository implements SettlementRepository {
  const UnconfiguredSettlementRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, SellerBalanceEntity>> getBalance() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> addBankAccount(AddBankAccountInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> deleteBankAccount(String bankAccountId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, String>> requestSettlement(RequestSettlementInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<SettlementEntity>>> getSettlements() async =>
      const Left(AuthFailure(_message));
}
