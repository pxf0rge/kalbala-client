import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';

class ListingModel {
  const ListingModel({
    required this.id,
    required this.productId,
    required this.boothId,
    required this.price,
    required this.stock,
    required this.status,
    this.sku,
    this.isFeatured = false,
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
  final String status;
  final bool isFeatured;
  final String? productName;
  final List<String> productImages;
  final double? compareAtPrice;

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final images = json['product_images'] ?? json['images'];
    return ListingModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      boothId: json['booth_id'] as String,
      price: _parsePrice(json['price']),
      stock: json['stock'] as int? ?? 0,
      sku: json['sku'] as String?,
      status: json['status'] as String? ?? 'active',
      isFeatured: json['is_featured'] as bool? ?? false,
      productName: json['product_name'] as String? ??
          (json['products'] is Map ? (json['products'] as Map)['name'] as String? : null),
      productImages: _parseImages(images),
      compareAtPrice: PublicListingModel._parseNullablePrice(json['compare_at_price']),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'product_id': productId,
      'booth_id': boothId,
      'price': price,
      'stock': stock,
      'sku': sku,
      'status': status,
      'is_featured': isFeatured,
      'compare_at_price': compareAtPrice,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'price': price,
      'stock': stock,
      'sku': sku,
      'status': status,
      'is_featured': isFeatured,
      'compare_at_price': compareAtPrice,
    };
  }

  ListingEntity toEntity({List<ListingVariantModel> variants = const []}) {
    return ListingEntity(
      id: id,
      productId: productId,
      boothId: boothId,
      price: price,
      stock: stock,
      sku: sku,
      status: ListingStatus.fromDb(status),
      isFeatured: isFeatured,
      variants: variants.map((v) => v.toEntity()).toList(),
      productName: productName,
      productImages: productImages,
      compareAtPrice: compareAtPrice,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseImages(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

class ListingVariantModel {
  const ListingVariantModel({
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

  factory ListingVariantModel.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    final attributes = <String, String>{};
    if (attrs is Map) {
      attrs.forEach((key, value) => attributes['$key'] = '$value');
    }
    return ListingVariantModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      name: json['name'] as String,
      attributes: attributes,
      price: ListingModel._parsePrice(json['price']),
      stock: json['stock'] as int? ?? 0,
      sku: json['sku'] as String?,
      compareAtPrice: PublicListingModel._parseNullablePrice(json['compare_at_price']),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'listing_id': listingId,
        'name': name,
        'attributes': attributes,
        'price': price,
        'stock': stock,
        'sku': sku,
        'compare_at_price': compareAtPrice,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'attributes': attributes,
        'price': price,
        'stock': stock,
        'sku': sku,
        'compare_at_price': compareAtPrice,
      };

  ListingVariantEntity toEntity() {
    return ListingVariantEntity(
      id: id,
      listingId: listingId,
      name: name,
      attributes: attributes,
      price: price,
      stock: stock,
      sku: sku,
      compareAtPrice: compareAtPrice,
    );
  }
}

class PublicListingModel {
  const PublicListingModel({
    required this.id,
    required this.productId,
    required this.boothId,
    required this.price,
    required this.stock,
    required this.productName,
    required this.boothName,
    required this.boothSlug,
    this.rawStock,
    this.productDescription,
    this.productImages = const [],
    this.weightGrams = 0,
    this.hasVariants = false,
    this.productBrand,
    this.boothLogoUrl,
    this.sku,
    this.compareAtPrice,
    this.categoryName,
  });

  final String id;
  final String productId;
  final String boothId;
  final double price;
  final int stock;
  final int? rawStock;
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
  final double? compareAtPrice;
  final String? categoryName;

  factory PublicListingModel.fromJson(Map<String, dynamic> json) {
    final rawStock = json['stock'] as int? ?? 0;
    final availableStock = json['available_stock'] as int? ?? rawStock;
    return PublicListingModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      boothId: json['booth_id'] as String,
      price: ListingModel._parsePrice(json['price']),
      stock: availableStock,
      rawStock: rawStock,
      sku: json['sku'] as String?,
      productName: json['product_name'] as String,
      productDescription: json['product_description'] as String?,
      productImages: ListingModel._parseImages(json['product_images']),
      weightGrams: json['weight_grams'] as int? ?? 0,
      hasVariants: json['has_variants'] as bool? ?? false,
      productBrand: json['product_brand'] as String?,
      boothName: json['booth_name'] as String,
      boothSlug: json['booth_slug'] as String,
      boothLogoUrl: json['booth_logo_url'] as String?,
      compareAtPrice: _parseNullablePrice(json['compare_at_price']),
      categoryName: json['category_name'] as String?,
    );
  }

  static double? _parseNullablePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  PublicListingEntity toEntity({List<ListingVariantModel> variants = const []}) {
    return PublicListingEntity(
      id: id,
      productId: productId,
      boothId: boothId,
      price: price,
      stock: stock,
      sku: sku,
      productName: productName,
      productDescription: productDescription,
      productImages: productImages,
      weightGrams: weightGrams,
      hasVariants: hasVariants,
      productBrand: productBrand,
      boothName: boothName,
      boothSlug: boothSlug,
      boothLogoUrl: boothLogoUrl,
      compareAtPrice: compareAtPrice,
      categoryName: categoryName,
      variants: variants.map((v) => v.toEntity()).toList(),
    );
  }
}
