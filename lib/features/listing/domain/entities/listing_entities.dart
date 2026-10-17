import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';

class ListingVariantEntity {
  const ListingVariantEntity({
    required this.id,
    required this.listingId,
    required this.name,
    required this.price,
    required this.stock,
    this.attributes = const {},
    this.sku,
    this.compareAtPrice,
  });

  final String id;
  final String listingId;
  final String name;
  final Map<String, String> attributes;
  final double price;
  final int stock;
  final String? sku;
  final double? compareAtPrice;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
}

class ListingEntity {
  const ListingEntity({
    required this.id,
    required this.productId,
    required this.boothId,
    required this.price,
    required this.stock,
    required this.status,
    this.sku,
    this.isFeatured = false,
    this.variants = const [],
    this.productName,
    this.productImages = const [],
    this.compareAtPrice,
  });

  final String id;
  final String productId;
  final String boothId;
  final double price;
  final int stock;
  final String? sku;
  final ListingStatus status;
  final bool isFeatured;
  final List<ListingVariantEntity> variants;
  final String? productName;
  final List<String> productImages;
  final double? compareAtPrice;

  String? get primaryImage => productImages.isNotEmpty ? productImages.first : null;
  bool get hasVariants => variants.isNotEmpty;
}

/// Buyer-facing listing from `public_listings` view.
class PublicListingEntity {
  const PublicListingEntity({
    required this.id,
    required this.productId,
    required this.boothId,
    required this.price,
    required this.stock,
    required this.productName,
    required this.boothName,
    required this.boothSlug,
    this.productDescription,
    this.productImages = const [],
    this.weightGrams = 0,
    this.hasVariants = false,
    this.productBrand,
    this.boothLogoUrl,
    this.sku,
    this.variants = const [],
    this.compareAtPrice,
    this.categoryName,
  });

  final String id;
  final String productId;
  final String boothId;
  final double price;
  final int stock;
  final String? sku;
  final String productName;
  final String? productDescription;
  final List<String> productImages;
  final int weightGrams;
  final bool hasVariants;
  final String? productBrand;
  final String boothName;
  final String boothSlug;
  final String? boothLogoUrl;
  final List<ListingVariantEntity> variants;
  final double? compareAtPrice;
  final String? categoryName;

  String? get primaryImage => productImages.isNotEmpty ? productImages.first : null;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
}
