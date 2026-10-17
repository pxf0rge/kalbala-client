import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/cart/presentation/widgets/cart_item_tile.dart';

/// Cart items grouped under a single booth.
class CartBoothGroup extends StatelessWidget {
  const CartBoothGroup({
    required this.group,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  final CartBoothGroupEntity group;
  final void Function(String cartItemId, int quantity) onQuantityChanged;
  final void Function(String cartItemId) onRemove;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push(RouteNames.publicBooth(group.boothSlug)),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    if (group.boothLogoUrl != null)
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(group.boothLogoUrl!),
                        radius: 16,
                      )
                    else
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(Icons.storefront, size: 16, color: AppColors.primary),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        group.boothName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Icon(Icons.chevron_left, size: 20, color: AppColors.inkMuted),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1, color: AppColors.hairline),
            ),
            ...group.items.map(
              (item) => CartItemTile(
                item: item,
                onQuantityChanged: (qty) => onQuantityChanged(item.id, qty),
                onRemove: () => onRemove(item.id),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'جمع فروشگاه: ${priceFormat.format(group.subtotal)} ${AppConstants.currencySymbol}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
