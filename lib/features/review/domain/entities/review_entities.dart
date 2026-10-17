/// Validates review rating and comment.
String? validateReviewInput({
  required int rating,
  String? comment,
  int maxCommentLength = 1000,
}) {
  if (rating < 1 || rating > 5) return 'امتیاز باید بین ۱ تا ۵ باشد.';
  if (comment != null && comment.trim().length > maxCommentLength) {
    return 'نظر حداکثر $maxCommentLength کاراکتر می‌تواند باشد.';
  }
  return null;
}

class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.rating,
    required this.buyerName,
    required this.createdAt,
    this.comment,
    this.productName,
    this.listingId,
  });

  final String id;
  final int rating;
  final String? comment;
  final String buyerName;
  final String? productName;
  final String? listingId;
  final DateTime createdAt;
}

class ReviewSummaryEntity {
  const ReviewSummaryEntity({
    required this.averageRating,
    required this.reviewCount,
  });

  final double averageRating;
  final int reviewCount;

  bool get hasReviews => reviewCount > 0;
}
