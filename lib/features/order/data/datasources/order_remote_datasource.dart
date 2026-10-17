import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<dynamic>> fetchMyOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  });

  Future<Map<String, dynamic>> fetchOrderDetail(String orderId);

  Future<List<dynamic>> fetchSellerOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  });

  Future<Map<String, dynamic>> fetchSellerOrderDetail(String sellerOrderId);

  Future<void> updateSellerOrderStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  });
}

final class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<dynamic>> fetchMyOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      final data = await _client.rpc(
        'get_my_orders',
        params: {
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchOrderDetail(String orderId) async {
    try {
      final data = await _client.rpc('get_order_detail', params: {'p_order_id': orderId});
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchSellerOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      final data = await _client.rpc(
        'get_seller_orders',
        params: {
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchSellerOrderDetail(String sellerOrderId) async {
    try {
      final data = await _client.rpc(
        'get_seller_order_detail',
        params: {'p_seller_order_id': sellerOrderId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> updateSellerOrderStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  }) async {
    try {
      await _client.rpc(
        'update_seller_order_status',
        params: {
          'p_seller_order_id': sellerOrderId,
          'p_new_status': newStatus.dbValue,
          'p_tracking_number': trackingNumber,
          'p_shipping_provider': shippingProvider,
        },
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
