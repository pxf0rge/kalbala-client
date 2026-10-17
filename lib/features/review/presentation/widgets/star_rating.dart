import 'package:flutter/material.dart';

/// Interactive or display-only star rating widget.
class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating,
    this.onChanged,
    this.size = 28,
    super.key,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = starValue <= rating;
        return IconButton(
          key: Key('star_$starValue'),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size + 4, height: size + 4),
          onPressed: onChanged == null ? null : () => onChanged!(starValue),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amber : Theme.of(context).colorScheme.outline,
            size: size,
          ),
        );
      }),
    );
  }
}

/// Read-only star display with optional numeric label.
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    required this.rating,
    this.reviewCount,
    super.key,
  });

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round().clamp(1, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRating(rating: rounded, size: 18),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
