import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<Map<String, dynamic>> placeOrder({
    required String addressId,
    required CheckoutPaymentMethod paymentMethod,
    String? cartId,
    String? buyerNote,
  });
}

final class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> placeOrder({
    required String addressId,
    required CheckoutPaymentMethod paymentMethod,
    String? cartId,
    String? buyerNote,
  }) async {
    try {
      final data = await _client.rpc(
        'place_order',
        params: {
          'p_address_id': addressId,
          'p_payment_method': paymentMethod.dbValue,
          'p_cart_id': cartId,
          'p_buyer_note': buyerNote,
        },
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
