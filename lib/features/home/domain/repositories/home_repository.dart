import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed();

  Future<Either<Failure, List<FeaturedBoothEntity>>> getFeaturedBooths({int limit = 10});

  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFeaturedProducts({
    int limit = 20,
  });

  Future<Either<Failure, List<CategorySummaryEntity>>> getCategories();

  Future<Either<Failure, List<CategorySummaryEntity>>> getChildCategories({
    String? parentId,
  });

  Future<Either<Failure, CategoryListingsPage>> getCategoryListings(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    CategorySortOption sort = CategorySortOption.newest,
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  });

  Future<Either<Failure, FeaturedBoothEntity?>> getPublicBooth(String slug);

  Future<Either<Failure, void>> incrementBoothView(String boothId);

  Future<Either<Failure, List<BannerEntity>>> getBanners();

  Future<Either<Failure, List<FeaturedBoothEntity>>> getNewBooths({int limit = 10});

  Future<Either<Failure, List<PublicListingSummaryEntity>>> getPopularProducts({
    int limit = 10,
  });

  Future<Either<Failure, List<PublicListingSummaryEntity>>> getRecentlyViewed({
    int limit = 12,
  });

  Future<Either<Failure, BoothSummaryEntity?>> getBoothSummary(String slug);
}

abstract interface class AnalyticsRepository {
  Future<Either<Failure, void>> trackEvent({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  });
}
