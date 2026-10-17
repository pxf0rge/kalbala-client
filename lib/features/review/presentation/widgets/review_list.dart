import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';
import 'package:rahmani_project/features/review/presentation/providers/review_provider.dart';
import 'package:rahmani_project/features/review/presentation/widgets/review_card.dart';
import 'package:rahmani_project/features/review/presentation/widgets/star_rating.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Review list with optional summary for listing or booth pages.
class ReviewList extends ConsumerWidget {
  const ReviewList.listing({
    required this.listingId,
    super.key,
  })  : boothId = null,
        _mode = _ReviewListMode.listing;

  const ReviewList.booth({
    required this.boothId,
    super.key,
  })  : listingId = null,
        _mode = _ReviewListMode.booth;

  final String? listingId;
  final String? boothId;
  final _ReviewListMode _mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = _mode == _ReviewListMode.listing
        ? ref.watch(listingReviewSummaryProvider(listingId!))
        : ref.watch(boothReviewSummaryProvider(boothId!));

    final reviewsAsync = _mode == _ReviewListMode.listing
        ? ref.watch(listingReviewsProvider(listingId!))
        : ref.watch(boothReviewsProvider(boothId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نظرات خریداران', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        summaryAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (ReviewSummaryEntity summary) {
            if (!summary.hasReviews) {
              return Text(
                'هنوز نظری ثبت نشده است.',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return StarRatingDisplay(
              rating: summary.averageRating,
              reviewCount: summary.reviewCount,
            );
          },
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (_, _) => const Text('خطا در بارگذاری نظرات'),
          data: (reviews) {
            if (reviews.isEmpty) return const SizedBox.shrink();
            return Column(
              children: reviews
                  .map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ReviewCard(review: review),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

enum _ReviewListMode { listing, booth }
