import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';

/// Simple horizontal bar chart for top product sales.
class DashboardChart extends StatelessWidget {
  const DashboardChart({
    required this.products,
    super.key,
  });

  final List<TopProductEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final priceFormat = NumberFormat('#,##0', 'fa');
    final maxSales = products.map((p) => p.totalSales).reduce((a, b) => a > b ? a : b);

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نمودار فروش محصولات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...products.map((product) {
                final fraction = maxSales > 0 ? product.totalSales / maxSales : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.ink,
                                  ),
                            ),
                          ),
                          Text(
                            '${priceFormat.format(product.totalSales)} ${AppConstants.currencySymbol}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 8,
                          backgroundColor: AppColors.primarySoft,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
