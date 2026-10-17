import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';
import 'package:rahmani_project/features/payment/domain/repositories/payment_repository.dart';

class InitiatePayment {
  const InitiatePayment(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, InitiatePaymentResultEntity>> call(InitiatePaymentInput input) {
    if (input.orderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('شناسه سفارش نامعتبر است.')));
    }
    return _repository.initiatePayment(input);
  }
}

class GetPaymentStatus {
  const GetPaymentStatus(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, PaymentEntity>> call(String paymentId) {
    if (paymentId.isEmpty) {
      return Future.value(const Left(ValidationFailure('شناسه پرداخت نامعتبر است.')));
    }
    return _repository.getPaymentStatus(paymentId);
  }
}

class RetryPayment {
  const RetryPayment(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, InitiatePaymentResultEntity>> call({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  }) {
    if (orderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('شناسه سفارش نامعتبر است.')));
    }
    return _repository.retryPayment(orderId: orderId, gateway: gateway, returnUrl: returnUrl);
  }
}

class CompleteSandboxPayment {
  const CompleteSandboxPayment(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, PaymentEntity>> call({
    required String paymentId,
    required bool success,
  }) =>
      _repository.completeSandboxPayment(paymentId: paymentId, success: success);
}
