import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/domain/repositories/settlement_repository.dart';

class GetSellerBalance {
  const GetSellerBalance(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, SellerBalanceEntity>> call() => _repository.getBalance();
}

class GetBankAccounts {
  const GetBankAccounts(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, List<BankAccountEntity>>> call() => _repository.getBankAccounts();
}

class AddBankAccount {
  const AddBankAccount(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, String>> call(AddBankAccountInput input) {
    if (input.bankName.trim().isEmpty ||
        input.accountNumber.trim().isEmpty ||
        input.accountHolder.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('همه فیلدهای حساب بانکی الزامی است.')));
    }
    return _repository.addBankAccount(input);
  }
}

class DeleteBankAccount {
  const DeleteBankAccount(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, void>> call(String bankAccountId) {
    if (bankAccountId.isEmpty) {
      return Future.value(const Left(ValidationFailure('حساب بانکی نامعتبر است.')));
    }
    return _repository.deleteBankAccount(bankAccountId);
  }
}

class RequestSettlement {
  const RequestSettlement(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, String>> call(
    RequestSettlementInput input, {
    required double availableBalance,
  }) {
    final error = validateSettlementAmount(
      amount: input.amount,
      availableBalance: availableBalance,
    );
    if (error != null) {
      return Future.value(Left(ValidationFailure(error)));
    }
    if (input.bankAccountId.isEmpty) {
      return Future.value(const Left(ValidationFailure('حساب بانکی انتخاب نشده است.')));
    }
    return _repository.requestSettlement(input);
  }
}

class GetSettlementHistory {
  const GetSettlementHistory(this._repository);
  final SettlementRepository _repository;

  Future<Either<Failure, List<SettlementEntity>>> call() => _repository.getSettlements();
}
