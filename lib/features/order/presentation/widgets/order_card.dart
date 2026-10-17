import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_badge.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Buyer order list card.
class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, this.onTap, super.key});

  final OrderSummaryEntity order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'fa');

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OrderStatusBadge.orderStatus(order.status),
                ],
              ),
              const SizedBox(height: 12),
              RahmaniPriceText(
                formatted: priceFormat.format(order.totalAmount),
                symbol: AppConstants.currencySymbol,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${order.sellerOrderCount} فروشگاه • ${order.paymentMethod.label}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
