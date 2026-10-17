import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_enums.dart';

/// List tile for a settlement request in history.
class SettlementTile extends StatelessWidget {
  const SettlementTile({
    required this.settlement,
    super.key,
  });

  final SettlementEntity settlement;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');
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
                    '${priceFormat.format(settlement.amount)} ${AppConstants.currencySymbol}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: settlement.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${settlement.bankName} — ${settlement.accountHolder}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'درخواست: ${dateFormat.format(settlement.requestedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (settlement.processedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'پردازش: ${dateFormat.format(settlement.processedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (settlement.rejectionReason != null &&
                settlement.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'دلیل رد: ${settlement.rejectionReason}',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SettlementStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SettlementStatus.completed => Colors.green,
      SettlementStatus.rejected => Theme.of(context).colorScheme.error,
      SettlementStatus.processing => Colors.orange,
      SettlementStatus.requested => Theme.of(context).colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
