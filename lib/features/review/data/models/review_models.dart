import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';

class ReviewModels {
  static ReviewEntity fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['review_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      buyerName: json['buyer_name'] as String? ?? 'خریدار',
      productName: json['product_name'] as String?,
      listingId: json['listing_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static ReviewSummaryEntity summaryFromJson(Map<String, dynamic> json) {
    return ReviewSummaryEntity(
      averageRating: _parseAmount(json['average_rating']),
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
