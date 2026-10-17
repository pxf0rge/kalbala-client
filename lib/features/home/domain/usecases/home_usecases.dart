import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/domain/repositories/home_repository.dart';

class GetHomeFeed {
  const GetHomeFeed(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, HomeFeedEntity>> call() => _repository.getHomeFeed();
}

class GetFeaturedBooths {
  const GetFeaturedBooths(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, List<FeaturedBoothEntity>>> call({int limit = 10}) =>
      _repository.getFeaturedBooths(limit: limit);
}

class GetFeaturedProducts {
  const GetFeaturedProducts(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, List<PublicListingSummaryEntity>>> call({int limit = 20}) =>
      _repository.getFeaturedProducts(limit: limit);
}

class GetCategoryListings {
  const GetCategoryListings(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, CategoryListingsPage>> call(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    CategorySortOption sort = CategorySortOption.newest,
    double? minPrice,
    double? maxPrice,
    String? query,
    bool includeChildren = true,
  }) =>
      _repository.getCategoryListings(
        categoryId,
        limit: limit,
        offset: offset,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
        query: query,
        includeChildren: includeChildren,
      );
}

class GetChildCategories {
  const GetChildCategories(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, List<CategorySummaryEntity>>> call({String? parentId}) =>
      _repository.getChildCategories(parentId: parentId);
}

class GetPublicBooth {
  const GetPublicBooth(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, FeaturedBoothEntity?>> call(String slug) =>
      _repository.getPublicBooth(slug);
}

class IncrementBoothView {
  const IncrementBoothView(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, void>> call(String boothId) =>
      _repository.incrementBoothView(boothId);
}

class TrackEvent {
  const TrackEvent(this._repository);
  final AnalyticsRepository _repository;

  Future<Either<Failure, void>> call({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) =>
      _repository.trackEvent(
        eventType: eventType,
        entityType: entityType,
        entityId: entityId,
        metadata: metadata,
      );
}
