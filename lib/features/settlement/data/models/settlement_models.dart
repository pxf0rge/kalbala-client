import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_enums.dart';

class SettlementModels {
  static SellerBalanceEntity balanceFromJson(Map<String, dynamic> json) {
    return SellerBalanceEntity(
      sellerId: json['seller_id'] as String,
      availableBalance: _parseAmount(json['available_balance']),
      pendingBalance: _parseAmount(json['pending_balance']),
      totalEarned: _parseAmount(json['total_earned']),
      totalSettled: _parseAmount(json['total_settled']),
    );
  }

  static BankAccountEntity bankAccountFromJson(Map<String, dynamic> json) {
    return BankAccountEntity(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountHolder: json['account_holder'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt:
          json['verified_at'] != null ? DateTime.parse(json['verified_at'] as String) : null,
    );
  }

  static SettlementEntity settlementFromJson(Map<String, dynamic> json) {
    return SettlementEntity(
      id: json['settlement_id'] as String,
      amount: _parseAmount(json['amount']),
      status: SettlementStatus.fromDb(json['status'] as String? ?? 'requested'),
      requestedAt: DateTime.parse(json['requested_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      bankName: json['bank_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      accountHolder: json['account_holder'] as String? ?? '',
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
