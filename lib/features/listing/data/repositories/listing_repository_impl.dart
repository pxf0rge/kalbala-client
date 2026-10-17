import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:rahmani_project/features/listing/data/models/listing_models.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/repositories/listing_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl({
    required ListingRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ListingRemoteDataSource _remote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<ListingEntity> _toEntityWithVariants(ListingModel model) async {
    final variants = await _remote.fetchVariants(model.id);
    return model.toEntity(variants: variants);
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getBoothListings(String boothId) async {
    try {
      final models = await _remote.fetchBoothListings(boothId);
      final entities = <ListingEntity>[];
      for (final model in models) {
        entities.add(await _toEntityWithVariants(model));
      }
      return Right(entities);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> getListing(String listingId) async {
    try {
      final model = await _remote.fetchListing(listingId);
      return Right(await _toEntityWithVariants(model));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PublicListingEntity>> getPublicListing(String listingId) async {
    try {
      final model = await _remote.fetchPublicListing(listingId);
      final variants = await _remote.fetchVariants(listingId);
      final stockData = await _remote.fetchListingAvailableStocks(listingId);
      final enrichedVariants = _applyAvailableStocks(variants, stockData);
      return Right(model.toEntity(variants: enrichedVariants));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  List<ListingVariantModel> _applyAvailableStocks(
    List<ListingVariantModel> variants,
    Map<String, dynamic> stockData,
  ) {
    final variantStocks = <String, int>{};
    final variantRows = stockData['variants'] as List<dynamic>? ?? [];
    for (final row in variantRows) {
      final map = row as Map<String, dynamic>;
      final variantId = map['variant_id'] as String?;
      if (variantId != null) {
        variantStocks[variantId] = map['available_stock'] as int? ?? 0;
      }
    }

    return variants
        .map(
          (variant) => ListingVariantModel(
            id: variant.id,
            listingId: variant.listingId,
            name: variant.name,
            price: variant.price,
            stock: variantStocks[variant.id] ?? variant.stock,
            attributes: variant.attributes,
            sku: variant.sku,
            compareAtPrice: variant.compareAtPrice,
          ),
        )
        .toList();
  }

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getPublicBoothListings(
    String boothSlug,
  ) async {
    try {
      final models = await _remote.fetchPublicBoothListings(boothSlug);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothCatalogListings({
    required String boothId,
    String? categoryId,
    String sort = 'newest',
    int limit = 40,
    int offset = 0,
  }) async {
    try {
      final models = await _remote.fetchBoothCatalogListings(
        boothId: boothId,
        categoryId: categoryId,
        sort: sort,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothBestsellers(
    String boothId, {
    int limit = 8,
  }) async {
    try {
      final models = await _remote.fetchBoothBestsellers(boothId, limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothNewListings(
    String boothId, {
    int limit = 8,
  }) async {
    try {
      final models = await _remote.fetchBoothNewListings(boothId, limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getRelatedListings(
    String listingId, {
    int limit = 8,
  }) async {
    try {
      final models = await _remote.fetchRelatedListings(listingId, limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> createListing(ListingInput input) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final model = await _remote.insertListing(
        ListingModel(
          id: '',
          productId: input.productId,
          boothId: input.boothId,
          price: input.price,
          stock: input.stock,
          sku: input.sku,
          status: input.status.dbValue,
          isFeatured: input.isFeatured,
          compareAtPrice: input.compareAtPrice,
        ),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> updateListing({
    required String listingId,
    required ListingInput input,
  }) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final current = await _remote.fetchListing(listingId);
      final model = await _remote.updateListing(
        ListingModel(
          id: listingId,
          productId: current.productId,
          boothId: current.boothId,
          price: input.price,
          stock: input.stock,
          sku: input.sku,
          status: input.status.dbValue,
          isFeatured: input.isFeatured,
          compareAtPrice: input.compareAtPrice,
        ),
      );
      return Right(await _toEntityWithVariants(model));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String listingId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.deleteListing(listingId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ListingVariantEntity>> addVariant({
    required String listingId,
    required VariantInput input,
  }) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final model = await _remote.insertVariant(
        ListingVariantModel(
          id: '',
          listingId: listingId,
          name: input.name,
          attributes: input.attributes,
          price: input.price,
          stock: input.stock,
          sku: input.sku,
          compareAtPrice: input.compareAtPrice,
        ),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ListingVariantEntity>> updateVariant({
    required String variantId,
    required VariantInput input,
  }) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final current = await _remote.fetchVariant(variantId);
      final model = await _remote.updateVariant(
        ListingVariantModel(
          id: variantId,
          listingId: current.listingId,
          name: input.name,
          attributes: input.attributes,
          price: input.price,
          stock: input.stock,
          sku: input.sku,
          compareAtPrice: input.compareAtPrice,
        ),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVariant(String variantId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.deleteVariant(variantId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredListingRepository implements ListingRepository {
  const UnconfiguredListingRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<ListingEntity>>> getBoothListings(String boothId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ListingEntity>> getListing(String listingId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, PublicListingEntity>> getPublicListing(String listingId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getPublicBoothListings(
    String boothSlug,
  ) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothCatalogListings({
    required String boothId,
    String? categoryId,
    String sort = 'newest',
    int limit = 40,
    int offset = 0,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothBestsellers(
    String boothId, {
    int limit = 8,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getBoothNewListings(
    String boothId, {
    int limit = 8,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingEntity>>> getRelatedListings(
    String listingId, {
    int limit = 8,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ListingEntity>> createListing(ListingInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ListingEntity>> updateListing({
    required String listingId,
    required ListingInput input,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> deleteListing(String listingId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ListingVariantEntity>> addVariant({
    required String listingId,
    required VariantInput input,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ListingVariantEntity>> updateVariant({
    required String variantId,
    required VariantInput input,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> deleteVariant(String variantId) async =>
      const Left(AuthFailure(_message));
}
