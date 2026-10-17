import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';

abstract interface class ReviewRepository {
  Future<Either<Failure, String>> submitReview({
    required String orderItemId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, bool>> canReview(String orderItemId);

  Future<Either<Failure, List<ReviewEntity>>> getListingReviews(String listingId);

  Future<Either<Failure, List<ReviewEntity>>> getBoothReviews(String boothId);

  Future<Either<Failure, ReviewSummaryEntity>> getListingReviewSummary(String listingId);

  Future<Either<Failure, ReviewSummaryEntity>> getBoothReviewSummary(String boothId);
}
