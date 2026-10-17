import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/data/datasources/analytics_remote_datasource.dart';
import 'package:rahmani_project/features/home/data/datasources/home_remote_datasource.dart';
import 'package:rahmani_project/features/home/data/models/home_models.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/domain/repositories/home_repository.dart';

final class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed() async {
    try {
      final results = await Future.wait([
        _remote.fetchFeaturedBooths(),
        _remote.fetchFeaturedProducts(),
        _remote.fetchCategories(),
        _remote.fetchBanners(),
        _remote.fetchNewBooths(),
        _remote.fetchPopularProducts(),
        _remote.fetchRecentlyViewed(),
      ]);
      return Right(
        HomeFeedEntity(
          featuredBooths: (results[0] as List<FeaturedBoothModel>)
              .map((m) => m.toEntity())
              .toList(),
          featuredProducts: (results[1] as List<PublicListingSummaryModel>)
              .map((m) => m.toEntity())
              .toList(),
          categories: (results[2] as List<CategorySummaryModel>)
              .map((m) => m.toEntity())
              .toList(),
          banners: (results[3] as List<BannerModel>).map((m) => m.toEntity()).toList(),
          newBooths: (results[4] as List<FeaturedBoothModel>)
              .map((m) => m.toEntity())
              .toList(),
          popularProducts: (results[5] as List<PublicListingSummaryModel>)
              .map((m) => m.toEntity())
              .toList(),
          recentlyViewed: (results[6] as List<PublicListingSummaryModel>)
              .map((m) => m.toEntity())
              .toList(),
        ),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getFeaturedBooths({int limit = 10}) async {
    try {
      final models = await _remote.fetchFeaturedBooths(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFeaturedProducts({
    int limit = 20,
  }) async {
    try {
      final models = await _remote.fetchFeaturedProducts(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CategorySummaryEntity>>> getCategories() async {
    try {
      final models = await _remote.fetchCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CategorySummaryEntity>>> getChildCategories({
    String? parentId,
  }) async {
    try {
      final models = await _remote.fetchChildCategories(parentId: parentId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CategoryListingsPage>> getCategoryListings(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    CategorySortOption sort = CategorySortOption.newest,
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  }) async {
    try {
      final models = await _remote.fetchCategoryListings(
        categoryId,
        limit: limit,
        offset: offset,
        sortBy: sort.dbValue,
        minPrice: minPrice,
        maxPrice: maxPrice,
        query: query,
        includeChildren: includeChildren,
      );
      final listings = models.map((m) => m.toEntity()).toList();
      return Right(
        CategoryListingsPage(
          listings: listings,
          hasMore: listings.length >= limit,
          offset: offset + listings.length,
        ),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FeaturedBoothEntity?>> getPublicBooth(String slug) async {
    try {
      final model = await _remote.fetchPublicBooth(slug);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> incrementBoothView(String boothId) async {
    try {
      await _remote.incrementBoothView(boothId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final models = await _remote.fetchBanners();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getNewBooths({int limit = 10}) async {
    try {
      final models = await _remote.fetchNewBooths(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getPopularProducts({
    int limit = 10,
  }) async {
    try {
      final models = await _remote.fetchPopularProducts(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getRecentlyViewed({
    int limit = 12,
  }) async {
    try {
      final models = await _remote.fetchRecentlyViewed(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BoothSummaryEntity?>> getBoothSummary(String slug) async {
    try {
      final model = await _remote.fetchBoothSummary(slug);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredHomeRepository implements HomeRepository {
  const UnconfiguredHomeRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getFeaturedBooths({int limit = 10}) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFeaturedProducts({
    int limit = 20,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<CategorySummaryEntity>>> getCategories() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<CategorySummaryEntity>>> getChildCategories({
    String? parentId,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, CategoryListingsPage>> getCategoryListings(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    CategorySortOption sort = CategorySortOption.newest,
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, FeaturedBoothEntity?>> getPublicBooth(String slug) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> incrementBoothView(String boothId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getNewBooths({int limit = 10}) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getPopularProducts({
    int limit = 10,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getRecentlyViewed({
    int limit = 12,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, BoothSummaryEntity?>> getBoothSummary(String slug) async =>
      const Left(AuthFailure(_message));
}

final class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> trackEvent({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await _remote.trackEvent(
        eventType: eventType,
        entityType: entityType,
        entityId: entityId,
        metadata: metadata,
      );
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredAnalyticsRepository implements AnalyticsRepository {
  const UnconfiguredAnalyticsRepository();

  @override
  Future<Either<Failure, void>> trackEvent({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async =>
      const Right(null);
}
