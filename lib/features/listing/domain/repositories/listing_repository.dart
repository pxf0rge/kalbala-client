import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';

class ListingInput {
  const ListingInput({
    required this.productId,
    required this.boothId,
    required this.price,
    required this.stock,
    this.sku,
    this.status = ListingStatus.active,
    this.isFeatured = false,
    this.compareAtPrice,
  });

  final String productId;
  final String boothId;
  final double price;
  final int stock;
  final String? sku;
  final ListingStatus status;
  final bool isFeatured;
  final double? compareAtPrice;
}

class VariantInput {
  const VariantInput({
    required this.name,
    required this.price,
    required this.stock,
    this.attributes = const {},
    this.sku,
    this.compareAtPrice,
  });

  final String name;
  final double price;
  final int stock;
  final Map<String, String> attributes;
  final String? sku;
  final double? compareAtPrice;
}

abstract interface class ListingRepository {
  Future<Either<Failure, List<ListingEntity>>> getBoothListings(String boothId);

  Future<Either<Failure, ListingEntity>> getListing(String listingId);

  Future<Either<Failure, PublicListingEntity>> getPublicListing(String listingId);

  Future<Either<Failure, List<PublicListingEntity>>> getPublicBoothListings(String boothSlug);

  Future<Either<Failure, List<PublicListingEntity>>> getBoothCatalogListings({
    required String boothId,
    String? categoryId,
    String sort = 'newest',
    int limit = 40,
    int offset = 0,
  });

  Future<Either<Failure, List<PublicListingEntity>>> getBoothBestsellers(
    String boothId, {
    int limit = 8,
  });

  Future<Either<Failure, List<PublicListingEntity>>> getBoothNewListings(
    String boothId, {
    int limit = 8,
  });

  Future<Either<Failure, List<PublicListingEntity>>> getRelatedListings(
    String listingId, {
    int limit = 8,
  });

  Future<Either<Failure, ListingEntity>> createListing(ListingInput input);

  Future<Either<Failure, ListingEntity>> updateListing({
    required String listingId,
    required ListingInput input,
  });

  Future<Either<Failure, void>> deleteListing(String listingId);

  Future<Either<Failure, ListingVariantEntity>> addVariant({
    required String listingId,
    required VariantInput input,
  });

  Future<Either<Failure, ListingVariantEntity>> updateVariant({
    required String variantId,
    required VariantInput input,
  });

  Future<Either<Failure, void>> deleteVariant(String variantId);
}
