import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  });

  Future<Map<String, dynamic>> fetchPaymentStatus(String paymentId);

  Future<Map<String, dynamic>> completeSandboxPayment({
    required String paymentId,
    required bool success,
  });
}

final class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required PaymentGateway gateway,
    String? returnUrl,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'initiate-payment',
        body: {
          'order_id': orderId,
          'gateway': gateway.dbValue,
          if (returnUrl != null) 'return_url': returnUrl,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final message = data is Map ? data['error']?.toString() : null;
        throw app_errors.ServerException(message ?? 'خطا در شروع پرداخت');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on FunctionException catch (e) {
      throw app_errors.ServerException(e.details?.toString() ?? e.reasonPhrase ?? 'خطا در شروع پرداخت');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchPaymentStatus(String paymentId) async {
    try {
      final data = await _client.rpc('get_payment_status', params: {'p_payment_id': paymentId});
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> completeSandboxPayment({
    required String paymentId,
    required bool success,
  }) async {
    try {
      final data = await _client.rpc(
        'complete_sandbox_payment',
        params: {
          'p_payment_id': paymentId,
          'p_success': success,
        },
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
