/// Public booth summary for home/discovery.
class FeaturedBoothEntity {
  const FeaturedBoothEntity({
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

  /// Contact number exposed on public storefront (privacy-aware).
  String? get publicPhone =>
      showPhone && phone != null && phone!.trim().isNotEmpty ? phone!.trim() : null;

  FeaturedBoothEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? logoUrl,
    String? coverUrl,
    String? city,
    String? description,
    String? phone,
    bool? showPhone,
    int? viewCount,
    int? followerCount,
    String? ownerId,
  }) {
    return FeaturedBoothEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      city: city ?? this.city,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      showPhone: showPhone ?? this.showPhone,
      viewCount: viewCount ?? this.viewCount,
      followerCount: followerCount ?? this.followerCount,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}

/// Storefront banner displayed on the home screen.
class BannerEntity {
  const BannerEntity({
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
}

/// Aggregated booth storefront stats (rating, product count, categories).
class BoothSummaryEntity {
  const BoothSummaryEntity({
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
}

class BoothCategorySummary {
  const BoothCategorySummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;
}

class HomeFeedEntity {
  const HomeFeedEntity({
    required this.featuredBooths,
    required this.featuredProducts,
    required this.categories,
    this.banners = const [],
    this.newBooths = const [],
    this.popularProducts = const [],
    this.recentlyViewed = const [],
  });

  final List<FeaturedBoothEntity> featuredBooths;
  final List<PublicListingSummaryEntity> featuredProducts;
  final List<CategorySummaryEntity> categories;
  final List<BannerEntity> banners;
  final List<FeaturedBoothEntity> newBooths;
  final List<PublicListingSummaryEntity> popularProducts;
  final List<PublicListingSummaryEntity> recentlyViewed;
}

/// Lightweight listing for grids/carousels.
class PublicListingSummaryEntity {
  const PublicListingSummaryEntity({
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

  String? get primaryImage => productImages.isNotEmpty ? productImages.first : null;

  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price;
}

class CategorySummaryEntity {
  const CategorySummaryEntity({
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

  bool get isRoot => parentId == null;
}

/// Paginated category listings result.
class CategoryListingsPage {
  const CategoryListingsPage({
    required this.listings,
    required this.hasMore,
    required this.offset,
    this.filters = const CategoryBrowseFilters(),
  });

  final List<PublicListingSummaryEntity> listings;
  final bool hasMore;
  final int offset;
  final CategoryBrowseFilters filters;

  static const pageSize = 20;
}

/// Filters for browsing products inside a category.
class CategoryBrowseFilters {
  const CategoryBrowseFilters({
    this.sort = CategorySortOption.newest,
    this.minPrice,
    this.maxPrice,
    this.query = '',
    this.selectedChildId,
  });

  final CategorySortOption sort;
  final double? minPrice;
  final double? maxPrice;
  final String query;
  /// When set, listings are scoped to this child (still includes its descendants).
  final String? selectedChildId;

  bool get hasActiveFilters =>
      minPrice != null || maxPrice != null || query.trim().isNotEmpty;

  CategoryBrowseFilters copyWith({
    CategorySortOption? sort,
    double? minPrice,
    double? maxPrice,
    String? query,
    String? selectedChildId,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearSelectedChildId = false,
  }) {
    return CategoryBrowseFilters(
      sort: sort ?? this.sort,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      query: query ?? this.query,
      selectedChildId:
          clearSelectedChildId ? null : (selectedChildId ?? this.selectedChildId),
    );
  }
}

enum CategorySortOption {
  newest,
  priceAsc,
  priceDesc,
  popular;

  String get dbValue => switch (this) {
        CategorySortOption.newest => 'newest',
        CategorySortOption.priceAsc => 'price_asc',
        CategorySortOption.priceDesc => 'price_desc',
        CategorySortOption.popular => 'popular',
      };

  String get labelFa => switch (this) {
        CategorySortOption.newest => 'جدیدترین',
        CategorySortOption.priceAsc => 'ارزان‌ترین',
        CategorySortOption.priceDesc => 'گران‌ترین',
        CategorySortOption.popular => 'محبوب',
      };
}
