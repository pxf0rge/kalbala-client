import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';

/// Shipping cost breakdown per booth at checkout.
class ShippingCostBreakdown extends StatelessWidget {
  const ShippingCostBreakdown({
    required this.summary,
    this.city,
    super.key,
  });

  final CheckoutSummaryEntity summary;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    if (summary.shippingTotal <= 0 && summary.boothGroups.every((g) => g.shippingCost <= 0)) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هزینه ارسال', style: Theme.of(context).textTheme.titleMedium),
            if (city != null && city!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'مقصد: $city',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            ...summary.boothGroups.map(
              (group) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(group.boothName)),
                    Text(
                      '${priceFormat.format(group.shippingCost)} ${AppConstants.currencySymbol}',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Expanded(child: Text('جمع هزینه ارسال')),
                Text(
                  '${priceFormat.format(summary.shippingTotal)} ${AppConstants.currencySymbol}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
