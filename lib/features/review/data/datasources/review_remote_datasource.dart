import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ReviewRemoteDataSource {
  Future<String> createReview({
    required String orderItemId,
    required int rating,
    String? comment,
  });

  Future<bool> checkCanReview(String orderItemId);

  Future<List<dynamic>> fetchListingReviews(String listingId);

  Future<List<dynamic>> fetchBoothReviews(String boothId);

  Future<Map<String, dynamic>> fetchListingSummary(String listingId);

  Future<Map<String, dynamic>> fetchBoothSummary(String boothId);
}

final class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) async {
    try {
      final data = await _client.rpc(
        'submit_review',
        params: {
          'p_order_item_id': orderItemId,
          'p_rating': rating,
          'p_comment': comment,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<bool> checkCanReview(String orderItemId) async {
    try {
      final data = await _client.rpc(
        'can_review_order_item',
        params: {'p_order_item_id': orderItemId},
      );
      return data as bool? ?? false;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchListingReviews(String listingId) async {
    try {
      final data = await _client.rpc(
        'get_listing_reviews',
        params: {'p_listing_id': listingId},
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchBoothReviews(String boothId) async {
    try {
      final data = await _client.rpc(
        'get_booth_reviews',
        params: {'p_booth_id': boothId},
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchListingSummary(String listingId) async {
    try {
      final data = await _client.rpc(
        'get_listing_review_summary',
        params: {'p_listing_id': listingId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchBoothSummary(String boothId) async {
    try {
      final data = await _client.rpc(
        'get_booth_review_summary',
        params: {'p_booth_id': boothId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
