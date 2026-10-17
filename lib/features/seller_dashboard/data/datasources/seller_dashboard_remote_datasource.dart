import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SellerDashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchDashboardStats(String sellerId);
}

final class SellerDashboardRemoteDataSourceImpl implements SellerDashboardRemoteDataSource {
  SellerDashboardRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> fetchDashboardStats(String sellerId) async {
    try {
      final data = await _client.rpc(
        'get_seller_dashboard_stats',
        params: {'p_seller_id': sellerId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
