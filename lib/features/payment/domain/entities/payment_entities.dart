import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';

class PaymentAttemptEntity {
  const PaymentAttemptEntity({
    required this.attemptId,
    required this.attemptNumber,
    required this.status,
    this.paymentUrl,
    this.failureReason,
    this.createdAt,
    this.completedAt,
  });

  final String attemptId;
  final int attemptNumber;
  final PaymentStatus status;
  final String? paymentUrl;
  final String? failureReason;
  final DateTime? createdAt;
  final DateTime? completedAt;
}

class PaymentEntity {
  const PaymentEntity({
    required this.paymentId,
    required this.orderId,
    required this.gateway,
    required this.amount,
    required this.status,
    this.gatewayReference,
    this.paidAt,
    this.failedAt,
    this.createdAt,
    this.latestAttempt,
  });

  final String paymentId;
  final String orderId;
  final PaymentGateway gateway;
  final double amount;
  final PaymentStatus status;
  final String? gatewayReference;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? createdAt;
  final PaymentAttemptEntity? latestAttempt;

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get canRetry => status == PaymentStatus.failed || status == PaymentStatus.pending;
}

class InitiatePaymentResultEntity {
  const InitiatePaymentResultEntity({
    required this.paymentId,
    required this.attemptId,
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.gateway,
    required this.gatewayReference,
    this.paymentUrl,
    this.sandbox = false,
  });

  final String paymentId;
  final String attemptId;
  final String orderId;
  final String orderNumber;
  final double amount;
  final PaymentGateway gateway;
  final String gatewayReference;
  final String? paymentUrl;
  final bool sandbox;
}

class OrderPaymentSummaryEntity {
  const OrderPaymentSummaryEntity({
    required this.paymentId,
    required this.gateway,
    required this.amount,
    required this.status,
    this.gatewayReference,
    this.paidAt,
    this.failedAt,
    this.canRetry = false,
  });

  final String paymentId;
  final PaymentGateway gateway;
  final double amount;
  final PaymentStatus status;
  final String? gatewayReference;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final bool canRetry;
}
