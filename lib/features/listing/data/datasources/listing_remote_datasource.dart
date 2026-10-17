import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/listing/data/models/listing_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ListingRemoteDataSource {
  Future<List<ListingModel>> fetchBoothListings(String boothId);

  Future<ListingModel> fetchListing(String listingId);

  Future<PublicListingModel> fetchPublicListing(String listingId);

  Future<Map<String, dynamic>> fetchListingAvailableStocks(String listingId);

  Future<List<PublicListingModel>> fetchPublicBoothListings(String boothSlug);

  Future<List<PublicListingModel>> fetchBoothCatalogListings({
    required String boothId,
    String? categoryId,
    String sort = 'newest',
    int limit = 40,
    int offset = 0,
  });

  Future<List<PublicListingModel>> fetchBoothBestsellers(String boothId, {int limit = 8});

  Future<List<PublicListingModel>> fetchBoothNewListings(String boothId, {int limit = 8});

  Future<List<PublicListingModel>> fetchRelatedListings(String listingId, {int limit = 8});

  Future<List<ListingVariantModel>> fetchVariants(String listingId);

  Future<ListingVariantModel> fetchVariant(String variantId);

  Future<ListingModel> insertListing(ListingModel listing);

  Future<ListingModel> updateListing(ListingModel listing);

  Future<void> deleteListing(String listingId);

  Future<ListingVariantModel> insertVariant(ListingVariantModel variant);

  Future<ListingVariantModel> updateVariant(ListingVariantModel variant);

  Future<void> deleteVariant(String variantId);
}

final class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  ListingRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _listingSelect =
      'id, product_id, booth_id, price, compare_at_price, stock, sku, status, is_featured, products(name, images)';

  @override
  Future<List<ListingModel>> fetchBoothListings(String boothId) async {
    try {
      final data = await _client
          .from('listings')
          .select(_listingSelect)
          .eq('booth_id', boothId)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => ListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingModel> fetchListing(String listingId) async {
    try {
      final data = await _client
          .from('listings')
          .select(_listingSelect)
          .eq('id', listingId)
          .single();
      return ListingModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PublicListingModel> fetchPublicListing(String listingId) async {
    try {
      final data = await _client
          .from('public_listings')
          .select()
          .eq('id', listingId)
          .single();
      return PublicListingModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchListingAvailableStocks(String listingId) async {
    try {
      final data = await _client.rpc(
        'get_listing_available_stocks',
        params: {'p_listing_id': listingId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingModel>> fetchPublicBoothListings(String boothSlug) async {
    try {
      final data = await _client
          .from('public_listings')
          .select()
          .eq('booth_slug', boothSlug)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => PublicListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingModel>> fetchBoothCatalogListings({
    required String boothId,
    String? categoryId,
    String sort = 'newest',
    int limit = 40,
    int offset = 0,
  }) async {
    try {
      final data = await _client.rpc(
        'get_booth_listings',
        params: {
          'p_booth_id': boothId,
          'p_category_id': categoryId,
          'p_sort': sort,
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      return (data as List<dynamic>)
          .map((row) => PublicListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingModel>> fetchBoothBestsellers(
    String boothId, {
    int limit = 8,
  }) async {
    try {
      final data = await _client.rpc(
        'get_booth_bestsellers',
        params: {'p_booth_id': boothId, 'p_limit': limit},
      );
      return (data as List<dynamic>)
          .map((row) => PublicListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingModel>> fetchBoothNewListings(
    String boothId, {
    int limit = 8,
  }) async {
    try {
      final data = await _client.rpc(
        'get_booth_new_listings',
        params: {'p_booth_id': boothId, 'p_limit': limit},
      );
      return (data as List<dynamic>)
          .map((row) => PublicListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PublicListingModel>> fetchRelatedListings(
    String listingId, {
    int limit = 8,
  }) async {
    try {
      final data = await _client.rpc(
        'get_related_listings',
        params: {'p_listing_id': listingId, 'p_limit': limit},
      );
      return (data as List<dynamic>)
          .map((row) => PublicListingModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingVariantModel> fetchVariant(String variantId) async {
    try {
      final data = await _client
          .from('listing_variants')
          .select()
          .eq('id', variantId)
          .single();
      return ListingVariantModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<ListingVariantModel>> fetchVariants(String listingId) async {
    try {
      final data = await _client
          .from('listing_variants')
          .select()
          .eq('listing_id', listingId)
          .order('created_at', ascending: true);
      return (data as List<dynamic>)
          .map((row) => ListingVariantModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingModel> insertListing(ListingModel listing) async {
    try {
      final data = await _client
          .from('listings')
          .insert(listing.toInsertJson())
          .select(_listingSelect)
          .single();
      return ListingModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingModel> updateListing(ListingModel listing) async {
    try {
      final data = await _client
          .from('listings')
          .update(listing.toUpdateJson())
          .eq('id', listing.id)
          .select(_listingSelect)
          .single();
      return ListingModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    try {
      await _client.from('listings').delete().eq('id', listingId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingVariantModel> insertVariant(ListingVariantModel variant) async {
    try {
      final data = await _client
          .from('listing_variants')
          .insert(variant.toInsertJson())
          .select()
          .single();
      return ListingVariantModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ListingVariantModel> updateVariant(ListingVariantModel variant) async {
    try {
      final data = await _client
          .from('listing_variants')
          .update(variant.toUpdateJson())
          .eq('id', variant.id)
          .select()
          .single();
      return ListingVariantModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    try {
      await _client.from('listing_variants').delete().eq('id', variantId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
