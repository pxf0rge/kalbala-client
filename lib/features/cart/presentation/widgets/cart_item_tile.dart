import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/cart/presentation/widgets/quantity_selector.dart';

/// Single cart line item with quantity controls.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  final CartItemEntity item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.primaryImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: CachedNetworkImage(
                  imageUrl: item.primaryImage!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.image_outlined, color: AppColors.inkMuted),
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: Theme.of(context).textTheme.titleSmall),
                  if (item.variantName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.variantName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${priceFormat.format(item.unitPrice)} ${AppConstants.currencySymbol}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (item.hasStockIssue) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.availableStock > 0
                          ? 'فقط ${item.availableStock} عدد باقی مانده'
                          : 'ناموجود',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ] else if (item.availableStock > 0 && item.availableStock <= 5) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'فقط ${item.availableStock} عدد باقی مانده',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.inkMuted,
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
                QuantitySelector(
                  quantity: item.quantity,
                  maxQuantity: item.availableStock,
                  onChanged: onQuantityChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
