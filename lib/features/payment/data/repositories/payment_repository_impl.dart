import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:rahmani_project/features/payment/data/models/payment_models.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';
import 'package:rahmani_project/features/payment/domain/repositories/payment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required PaymentRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final PaymentRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, InitiatePaymentResultEntity>> initiatePayment(
    InitiatePaymentInput input,
  ) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.initiatePayment(
        orderId: input.orderId,
        gateway: input.gateway,
        returnUrl: input.returnUrl,
      );
      return Right(PaymentModels.initiateFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentStatus(String paymentId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchPaymentStatus(paymentId);
      return Right(PaymentModels.statusFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, InitiatePaymentResultEntity>> retryPayment({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  }) =>
      initiatePayment(InitiatePaymentInput(orderId: orderId, gateway: gateway, returnUrl: returnUrl));

  @override
  Future<Either<Failure, PaymentEntity>> completeSandboxPayment({
    required String paymentId,
    required bool success,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.completeSandboxPayment(paymentId: paymentId, success: success);
      final data = await _remote.fetchPaymentStatus(paymentId);
      return Right(PaymentModels.statusFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredPaymentRepository implements PaymentRepository {
  const UnconfiguredPaymentRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, InitiatePaymentResultEntity>> initiatePayment(
    InitiatePaymentInput input,
  ) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentStatus(String paymentId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, InitiatePaymentResultEntity>> retryPayment({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, PaymentEntity>> completeSandboxPayment({
    required String paymentId,
    required bool success,
  }) async =>
      const Left(AuthFailure(_message));
}
