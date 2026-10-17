import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';

abstract interface class SettlementRepository {
  Future<Either<Failure, SellerBalanceEntity>> getBalance();

  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts();

  Future<Either<Failure, String>> addBankAccount(AddBankAccountInput input);

  Future<Either<Failure, void>> deleteBankAccount(String bankAccountId);

  Future<Either<Failure, String>> requestSettlement(RequestSettlementInput input);

  Future<Either<Failure, List<SettlementEntity>>> getSettlements();
}
