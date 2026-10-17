import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_badge.dart';

/// Seller order list card.
class SellerOrderCard extends StatelessWidget {
  const SellerOrderCard({required this.order, this.onTap, super.key});

  final SellerOrderSummaryEntity order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'fa');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.orderNumber, style: Theme.of(context).textTheme.titleSmall),
                  ),
                  OrderStatusBadge.sellerStatus(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.boothName, style: Theme.of(context).textTheme.bodyMedium),
              Text('خریدار: ${order.buyerName}'),
              const SizedBox(height: 8),
              Text(
                '${priceFormat.format(order.total)} ${AppConstants.currencySymbol}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text('${order.itemCount} قلم • ${dateFormat.format(order.createdAt)}'),
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 4),
                Text('رهگیری: ${order.trackingNumber}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
