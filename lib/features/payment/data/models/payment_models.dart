import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';

class PaymentModels {
  static InitiatePaymentResultEntity initiateFromJson(Map<String, dynamic> json) {
    return InitiatePaymentResultEntity(
      paymentId: json['payment_id'] as String,
      attemptId: json['attempt_id'] as String,
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      amount: _parseAmount(json['amount']),
      gateway: PaymentGateway.fromDb(json['gateway'] as String? ?? 'hesabpay'),
      gatewayReference: json['gateway_reference'] as String? ?? '',
      paymentUrl: json['payment_url'] as String?,
      sandbox: json['sandbox'] as bool? ?? false,
    );
  }

  static PaymentEntity statusFromJson(Map<String, dynamic> json) {
    final attemptJson = json['latest_attempt'] as Map<String, dynamic>?;
    return PaymentEntity(
      paymentId: json['payment_id'] as String,
      orderId: json['order_id'] as String,
      gateway: PaymentGateway.fromDb(json['gateway'] as String? ?? 'hesabpay'),
      amount: _parseAmount(json['amount']),
      status: PaymentStatus.fromDb(json['status'] as String? ?? 'pending'),
      gatewayReference: json['gateway_reference'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      failedAt: json['failed_at'] != null ? DateTime.parse(json['failed_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      latestAttempt: attemptJson != null ? attemptFromJson(attemptJson) : null,
    );
  }

  static PaymentAttemptEntity attemptFromJson(Map<String, dynamic> json) {
    return PaymentAttemptEntity(
      attemptId: json['attempt_id'] as String,
      attemptNumber: (json['attempt_number'] as num?)?.toInt() ?? 1,
      status: PaymentStatus.fromDb(json['status'] as String? ?? 'pending'),
      paymentUrl: json['payment_url'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      completedAt:
          json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  static OrderPaymentSummaryEntity orderPaymentFromJson(Map<String, dynamic> json) {
    return OrderPaymentSummaryEntity(
      paymentId: json['payment_id'] as String,
      gateway: PaymentGateway.fromDb(json['gateway'] as String? ?? 'hesabpay'),
      amount: _parseAmount(json['amount']),
      status: PaymentStatus.fromDb(json['status'] as String? ?? 'pending'),
      gatewayReference: json['gateway_reference'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      failedAt: json['failed_at'] != null ? DateTime.parse(json['failed_at'] as String) : null,
      canRetry: json['can_retry'] as bool? ?? false,
    );
  }

  static PaymentEntity webhookResultToPayment(Map<String, dynamic> json) {
    return PaymentEntity(
      paymentId: json['payment_id'] as String,
      orderId: json['order_id'] as String,
      gateway: PaymentGateway.hesabpay,
      amount: 0,
      status: PaymentStatus.fromDb(json['status'] as String? ?? 'pending'),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
