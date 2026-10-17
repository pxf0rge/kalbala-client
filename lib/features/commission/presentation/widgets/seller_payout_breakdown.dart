import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/commission/domain/entities/commission_entities.dart';

/// Seller payout breakdown with commission info.
class SellerPayoutBreakdown extends StatelessWidget {
  const SellerPayoutBreakdown({
    required this.breakdown,
    super.key,
  });

  final CommissionBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تسویه فروشنده', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _Row(
              label: 'جمع اقلام',
              value: '${priceFormat.format(breakdown.subtotal)} ${AppConstants.currencySymbol}',
            ),
            const SizedBox(height: 8),
            _Row(
              label: breakdown.commissionLabel,
              value: '- ${priceFormat.format(breakdown.commissionAmount)} ${AppConstants.currencySymbol}',
              valueColor: breakdown.commissionAmount > 0
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'سهم فروشنده (اقلام)',
              value: '${priceFormat.format(breakdown.sellerPayout)} ${AppConstants.currencySymbol}',
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'هزینه ارسال',
              value: '${priceFormat.format(breakdown.shippingCost)} ${AppConstants.currencySymbol}',
            ),
            const Divider(height: 24),
            _Row(
              label: 'درآمد خالص',
              value: '${priceFormat.format(breakdown.netEarnings)} ${AppConstants.currencySymbol}',
              isBold: true,
            ),
            if (!breakdown.commissionEnabled) ...[
              const SizedBox(height: 8),
              Text(
                'کارمزد در حال حاضر غیرفعال است (دوره رایگان).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
