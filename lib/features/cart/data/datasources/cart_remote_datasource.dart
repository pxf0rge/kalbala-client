import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CartRemoteDataSource {
  Future<List<dynamic>> fetchCartDetails();

  Future<void> addToCart({
    required String listingId,
    String? variantId,
    required int quantity,
  });

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<void> removeItem(String cartItemId);

  Future<void> clearCart();
}

final class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<dynamic>> fetchCartDetails() async {
    try {
      final data = await _client.rpc('get_cart_details');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> addToCart({
    required String listingId,
    String? variantId,
    required int quantity,
  }) async {
    try {
      await _client.rpc(
        'add_to_cart_item',
        params: {
          'p_listing_id': listingId,
          'p_variant_id': variantId,
          'p_quantity': quantity,
        },
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _client.rpc(
        'update_cart_item_quantity',
        params: {
          'p_cart_item_id': cartItemId,
          'p_quantity': quantity,
        },
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    try {
      await _client.rpc('remove_cart_item', params: {'p_cart_item_id': cartItemId});
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _client.rpc('clear_cart');
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
