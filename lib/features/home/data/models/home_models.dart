import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

class FeaturedBoothModel {
  const FeaturedBoothModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.coverUrl,
    this.city,
    this.description,
    this.phone,
    this.showPhone = true,
    this.viewCount = 0,
    this.followerCount = 0,
    this.ownerId,
  });

  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverUrl;
  final String? city;
  final String? description;
  final String? phone;
  final bool showPhone;
  final int viewCount;
  final int followerCount;
  final String? ownerId;

  factory FeaturedBoothModel.fromJson(Map<String, dynamic> json) {
    return FeaturedBoothModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      city: json['city'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      showPhone: json['show_phone'] as bool? ?? true,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      ownerId: json['owner_id'] as String?,
    );
  }

  FeaturedBoothEntity toEntity() {
    return FeaturedBoothEntity(
      id: id,
      name: name,
      slug: slug,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      city: city,
      description: description,
      phone: phone,
      showPhone: showPhone,
      viewCount: viewCount,
      followerCount: followerCount,
      ownerId: ownerId,
    );
  }
}

class PublicListingSummaryModel {
  const PublicListingSummaryModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.boothSlug,
    this.productImages = const [],
    this.boothName,
    this.categoryId,
    this.compareAtPrice,
    this.categoryName,
  });

  final String id;
  final String productName;
  final double price;
  final String boothSlug;
  final List<String> productImages;
  final String? boothName;
  final String? categoryId;
  final double? compareAtPrice;
  final String? categoryName;

  factory PublicListingSummaryModel.fromJson(Map<String, dynamic> json) {
    final images = json['product_images'];
    return PublicListingSummaryModel(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      price: _parsePrice(json['price']),
      boothSlug: json['booth_slug'] as String,
      productImages: images is List ? images.map((e) => e.toString()).toList() : [],
      boothName: json['booth_name'] as String?,
      categoryId: json['category_id'] as String?,
      compareAtPrice: _parseNullablePrice(json['compare_at_price']),
      categoryName: json['category_name'] as String?,
    );
  }

  PublicListingSummaryEntity toEntity() {
    return PublicListingSummaryEntity(
      id: id,
      productName: productName,
      price: price,
      boothSlug: boothSlug,
      productImages: productImages,
      boothName: boothName,
      categoryId: categoryId,
      compareAtPrice: compareAtPrice,
      categoryName: categoryName,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseNullablePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class CategorySummaryModel {
  const CategorySummaryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.parentId,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? parentId;
  final int sortOrder;

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) {
    return CategorySummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      iconUrl: json['icon_url'] as String?,
      parentId: json['parent_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  CategorySummaryEntity toEntity() {
    return CategorySummaryEntity(
      id: id,
      name: name,
      slug: slug,
      iconUrl: iconUrl,
      parentId: parentId,
      sortOrder: sortOrder,
    );
  }
}

class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.linkType = 'none',
    this.linkTargetId,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String linkType;
  final String? linkTargetId;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      linkUrl: json['link_url'] as String?,
      linkType: json['link_type'] as String? ?? 'none',
      linkTargetId: json['link_target_id'] as String?,
    );
  }

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      title: title,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      linkType: linkType,
      linkTargetId: linkTargetId,
    );
  }
}

class BoothSummaryModel {
  const BoothSummaryModel({
    required this.boothId,
    this.productCount = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.categories = const [],
  });

  final String boothId;
  final int productCount;
  final double averageRating;
  final int reviewCount;
  final List<BoothCategorySummary> categories;

  factory BoothSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    final categories = <BoothCategorySummary>[];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map) {
          categories.add(
            BoothCategorySummary(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
              slug: item['slug']?.toString() ?? '',
            ),
          );
        }
      }
    }
    return BoothSummaryModel(
      boothId: json['booth_id'] as String? ?? '',
      productCount: json['product_count'] as int? ?? 0,
      averageRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      categories: categories,
    );
  }

  BoothSummaryEntity toEntity() {
    return BoothSummaryEntity(
      boothId: boothId,
      productCount: productCount,
      averageRating: averageRating,
      reviewCount: reviewCount,
      categories: categories,
    );
  }
}
