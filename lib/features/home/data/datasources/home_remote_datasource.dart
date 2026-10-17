import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/home/data/models/home_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<FeaturedBoothModel>> fetchFeaturedBooths({int limit = 10});

  Future<List<PublicListingSummaryModel>> fetchFeaturedProducts({int limit = 20});

  Future<List<CategorySummaryModel>> fetchCategories();

  Future<List<CategorySummaryModel>> fetchChildCategories({String? parentId});

  Future<List<PublicListingSummaryModel>> fetchCategoryListings(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    String sortBy = 'newest',
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  });

  Future<FeaturedBoothModel?> fetchPublicBooth(String slug);

  Future<void> incrementBoothView(String boothId);

  Future<List<BannerModel>> fetchBanners();

  Future<List<FeaturedBoothModel>> fetchNewBooths({int limit = 10});

  Future<List<PublicListingSummaryModel>> fetchPopularProducts({int limit = 10});

  Future<List<PublicListingSummaryModel>> fetchRecentlyViewed({int limit = 12});

  Future<BoothSummaryModel?> fetchBoothSummary(String slug);
}

final class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<FeaturedBoothModel>> fetchFeaturedBooths({int limit = 10}) async {
    try {
      final data = await _client.rpc('get_featured_booths', params: {'p_limit': limit});
      return (data as List<dynamic>)
          .map((row) => FeaturedBoothModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingSummaryModel>> fetchFeaturedProducts({int limit = 20}) async {
    try {
      final data = await _client.rpc('get_featured_listings', params: {'p_limit': limit});
      return (data as List<dynamic>)
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<CategorySummaryModel>> fetchCategories() async {
    try {
      // Home rail: root categories only.
      final data = await _client.rpc('get_child_categories');
      return (data as List<dynamic>)
          .map((row) => CategorySummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<CategorySummaryModel>> fetchChildCategories({String? parentId}) async {
    try {
      final data = await _client.rpc(
        'get_child_categories',
        params: {'p_parent_id': parentId},
      );
      return (data as List<dynamic>)
          .map((row) => CategorySummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingSummaryModel>> fetchCategoryListings(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    String sortBy = 'newest',
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  }) async {
    try {
      final data = await _client.rpc(
        'get_listings_by_category',
        params: {
          'p_category_id': categoryId,
          'p_limit': limit,
          'p_offset': offset,
          'p_sort_by': sortBy,
          'p_min_price': minPrice,
          'p_max_price': maxPrice,
          'p_query': query,
          'p_include_children': includeChildren,
        },
      );
      return (data as List<dynamic>)
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<FeaturedBoothModel?> fetchPublicBooth(String slug) async {
    try {
      final data = await _client.rpc('get_public_booth_by_slug', params: {'p_slug': slug});
      if (data == null) return null;
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);
      return FeaturedBoothModel.fromJson(map);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> incrementBoothView(String boothId) async {
    try {
      await _client.rpc('increment_booth_view', params: {'p_booth_id': boothId});
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final data = await _client.rpc('get_active_banners');
      final raw = data as List<dynamic>? ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(BannerModel.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<FeaturedBoothModel>> fetchNewBooths({int limit = 10}) async {
    try {
      final data = await _client.rpc('get_new_booths', params: {'p_limit': limit});
      return (data as List<dynamic>)
          .map((row) => FeaturedBoothModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingSummaryModel>> fetchPopularProducts({int limit = 10}) async {
    try {
      final data = await _client.rpc('get_popular_products', params: {'p_limit': limit});
      return (data as List<dynamic>)
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingSummaryModel>> fetchRecentlyViewed({int limit = 12}) async {
    try {
      final data = await _client.rpc('get_recently_viewed', params: {'p_limit': limit});
      return (data as List<dynamic>)
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BoothSummaryModel?> fetchBoothSummary(String slug) async {
    try {
      final data = await _client.rpc('get_booth_summary', params: {'p_slug': slug});
      if (data == null) return null;
      return BoothSummaryModel.fromJson(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
