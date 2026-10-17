import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/review/data/datasources/review_remote_datasource.dart';
import 'package:rahmani_project/features/review/data/models/review_models.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';
import 'package:rahmani_project/features/review/domain/repositories/review_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({
    required ReviewRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ReviewRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, String>> submitReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final id = await _remote.createReview(
        orderItemId: orderItemId,
        rating: rating,
        comment: comment,
      );
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> canReview(String orderItemId) async {
    try {
      if (_client.auth.currentUser == null) return const Right(false);
      final can = await _remote.checkCanReview(orderItemId);
      return Right(can);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getListingReviews(String listingId) async {
    try {
      final rows = await _remote.fetchListingReviews(listingId);
      return Right(
        rows.map((row) => ReviewModels.fromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getBoothReviews(String boothId) async {
    try {
      final rows = await _remote.fetchBoothReviews(boothId);
      return Right(
        rows.map((row) => ReviewModels.fromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ReviewSummaryEntity>> getListingReviewSummary(
    String listingId,
  ) async {
    try {
      final data = await _remote.fetchListingSummary(listingId);
      return Right(ReviewModels.summaryFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ReviewSummaryEntity>> getBoothReviewSummary(String boothId) async {
    try {
      final data = await _remote.fetchBoothSummary(boothId);
      return Right(ReviewModels.summaryFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredReviewRepository implements ReviewRepository {
  const UnconfiguredReviewRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, String>> submitReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, bool>> canReview(String orderItemId) async => const Right(false);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getListingReviews(String listingId) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getBoothReviews(String boothId) async =>
      const Right([]);

  @override
  Future<Either<Failure, ReviewSummaryEntity>> getListingReviewSummary(String listingId) async =>
      const Right(ReviewSummaryEntity(averageRating: 0, reviewCount: 0));

  @override
  Future<Either<Failure, ReviewSummaryEntity>> getBoothReviewSummary(String boothId) async =>
      const Right(ReviewSummaryEntity(averageRating: 0, reviewCount: 0));
}
