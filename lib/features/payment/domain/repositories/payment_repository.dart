import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';

class InitiatePaymentInput {
  const InitiatePaymentInput({
    required this.orderId,
    required this.gateway,
    this.returnUrl,
  });

  final String orderId;
  final PaymentGateway gateway;
  final String? returnUrl;
}

abstract interface class PaymentRepository {
  Future<Either<Failure, InitiatePaymentResultEntity>> initiatePayment(
    InitiatePaymentInput input,
  );

  Future<Either<Failure, PaymentEntity>> getPaymentStatus(String paymentId);

  Future<Either<Failure, InitiatePaymentResultEntity>> retryPayment({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  });

  Future<Either<Failure, PaymentEntity>> completeSandboxPayment({
    required String paymentId,
    required bool success,
  });
}
