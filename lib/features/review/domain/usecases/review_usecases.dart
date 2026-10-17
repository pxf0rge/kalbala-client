import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';
import 'package:rahmani_project/features/review/domain/repositories/review_repository.dart';

class SubmitReview {
  const SubmitReview(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, String>> call({
    required String orderItemId,
    required int rating,
    String? comment,
  }) {
    final error = validateReviewInput(rating: rating, comment: comment);
    if (error != null) {
      return Future.value(Left(ValidationFailure(error)));
    }
    if (orderItemId.isEmpty) {
      return Future.value(const Left(ValidationFailure('آیتم سفارش نامعتبر است.')));
    }
    return _repository.submitReview(
      orderItemId: orderItemId,
      rating: rating,
      comment: comment?.trim(),
    );
  }
}

class CanReviewOrderItem {
  const CanReviewOrderItem(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, bool>> call(String orderItemId) {
    if (orderItemId.isEmpty) {
      return Future.value(const Left(ValidationFailure('آیتم سفارش نامعتبر است.')));
    }
    return _repository.canReview(orderItemId);
  }
}

class GetListingReviews {
  const GetListingReviews(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, List<ReviewEntity>>> call(String listingId) {
    if (listingId.isEmpty) {
      return Future.value(const Left(ValidationFailure('محصول نامعتبر است.')));
    }
    return _repository.getListingReviews(listingId);
  }
}

class GetBoothReviews {
  const GetBoothReviews(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, List<ReviewEntity>>> call(String boothId) {
    if (boothId.isEmpty) {
      return Future.value(const Left(ValidationFailure('فروشگاه نامعتبر است.')));
    }
    return _repository.getBoothReviews(boothId);
  }
}

class GetListingReviewSummary {
  const GetListingReviewSummary(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, ReviewSummaryEntity>> call(String listingId) =>
      _repository.getListingReviewSummary(listingId);
}

class GetBoothReviewSummary {
  const GetBoothReviewSummary(this._repository);
  final ReviewRepository _repository;

  Future<Either<Failure, ReviewSummaryEntity>> call(String boothId) =>
      _repository.getBoothReviewSummary(boothId);
}
