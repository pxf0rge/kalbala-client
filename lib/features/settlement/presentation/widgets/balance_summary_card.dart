import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';

/// Summary card showing seller balance metrics.
class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    required this.balance,
    super.key,
  });

  final SellerBalanceEntity balance;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('موجودی حساب', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _Row(
              label: 'قابل برداشت',
              value: '${priceFormat.format(balance.availableBalance)} ${AppConstants.currencySymbol}',
              isBold: true,
              valueColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'در انتظار تسویه',
              value: '${priceFormat.format(balance.pendingBalance)} ${AppConstants.currencySymbol}',
            ),
            const Divider(height: 24),
            _Row(
              label: 'کل درآمد',
              value: '${priceFormat.format(balance.totalEarned)} ${AppConstants.currencySymbol}',
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'کل تسویه‌شده',
              value: '${priceFormat.format(balance.totalSettled)} ${AppConstants.currencySymbol}',
            ),
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
        Text(value, style: style?.copyWith(color: valueColor)),
      ],
    );
  }
}
