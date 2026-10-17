import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ShippingRemoteDataSource {
  Future<Map<String, dynamic>> fetchCheckoutShippingPreview(String addressId);

  Future<double> calculateShippingCost({
    required String city,
    required int weightGrams,
  });
}

final class ShippingRemoteDataSourceImpl implements ShippingRemoteDataSource {
  ShippingRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> fetchCheckoutShippingPreview(String addressId) async {
    try {
      final data = await _client.rpc(
        'get_checkout_shipping_preview',
        params: {'p_address_id': addressId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<double> calculateShippingCost({
    required String city,
    required int weightGrams,
  }) async {
    try {
      final data = await _client.rpc(
        'calculate_shipping_cost',
        params: {
          'p_city': city,
          'p_weight_grams': weightGrams,
        },
      );
      if (data is num) return data.toDouble();
      return double.tryParse(data?.toString() ?? '') ?? 0;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
