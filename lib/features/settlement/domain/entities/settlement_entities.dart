import 'package:rahmani_project/features/settlement/domain/entities/settlement_enums.dart';

class SellerBalanceEntity {
  const SellerBalanceEntity({
    required this.sellerId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalSettled,
  });

  final String sellerId;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalSettled;
}

class BankAccountEntity {
  const BankAccountEntity({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.isVerified,
    this.verifiedAt,
  });

  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final bool isVerified;
  final DateTime? verifiedAt;

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}

class SettlementEntity {
  const SettlementEntity({
    required this.id,
    required this.amount,
    required this.status,
    required this.requestedAt,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.processedAt,
    this.rejectionReason,
  });

  final String id;
  final double amount;
  final SettlementStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? rejectionReason;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
}

class AddBankAccountInput {
  const AddBankAccountInput({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  final String bankName;
  final String accountNumber;
  final String accountHolder;
}

class RequestSettlementInput {
  const RequestSettlementInput({
    required this.amount,
    required this.bankAccountId,
  });

  final double amount;
  final String bankAccountId;
}

/// Validates settlement request against available balance.
String? validateSettlementAmount({
  required double amount,
  required double availableBalance,
}) {
  if (amount <= 0) return 'مبلغ نامعتبر است.';
  if (amount > availableBalance) return 'موجودی کافی نیست.';
  return null;
}

/// Full refund amount for a seller order (info.json #20).
double calculateFullRefundAmount({
  required double subtotal,
  required double shippingCost,
}) =>
    subtotal + shippingCost;
