import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';

/// Bottom bar showing cart total and checkout placeholder.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    required this.total,
    required this.itemCount,
    this.hasStockIssues = false,
    super.key,
  });

  final double total;
  final int itemCount;
  final bool hasStockIssues;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Material(
      color: AppColors.surfaceRaised,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasStockIssues)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'برخی اقلام موجودی کافی ندارند.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جمع کل ($itemCount قلم)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${priceFormat.format(total)} ${AppConstants.currencySymbol}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: hasStockIssues
                          ? null
                          : () => context.push(RouteNames.checkout),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text('پرداخت'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'آدرس تحویل و روش پرداخت در مرحله بعد انتخاب می‌شود',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
