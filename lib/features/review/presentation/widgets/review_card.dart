import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_action.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';
import 'package:rahmani_project/features/review/presentation/widgets/star_rating.dart';

/// Card displaying a single review.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.review,
    super.key,
  });

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd('fa');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.buyerName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                StarRating(rating: review.rating, size: 18),
                ReportIconButton(
                  target: ReportTarget(
                    type: ReportTargetType.review,
                    targetId: review.id,
                    label: review.productName ?? review.buyerName,
                  ),
                ),
              ],
            ),
            if (review.productName != null) ...[
              const SizedBox(height: 4),
              Text(
                review.productName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment!),
            ],
            const SizedBox(height: 8),
            Text(
              dateFormat.format(review.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
