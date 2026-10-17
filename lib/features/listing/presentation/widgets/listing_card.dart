import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Listing row / tile for seller and buyer lists.
class ListingCard extends StatelessWidget {
  const ListingCard({
    required this.title,
    required this.price,
    required this.stock,
    required this.status,
    this.imageUrl,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.compact = false,
    super.key,
  });

  factory ListingCard.fromEntity(ListingEntity listing, {VoidCallback? onTap, Widget? trailing}) {
    return ListingCard(
      title: listing.productName ?? 'محصول',
      price: listing.price,
      stock: listing.stock,
      status: listing.status,
      imageUrl: listing.primaryImage,
      subtitle: listing.sku,
      onTap: onTap,
      trailing: trailing,
    );
  }

  factory ListingCard.fromPublic(
    PublicListingEntity listing, {
    VoidCallback? onTap,
    bool compact = false,
  }) {
    return ListingCard(
      title: listing.productName,
      price: listing.price,
      stock: listing.stock,
      status: listing.stock > 0 ? ListingStatus.active : ListingStatus.outOfStock,
      imageUrl: listing.primaryImage,
      subtitle: listing.boothName,
      onTap: onTap,
      compact: compact,
    );
  }

  final String title;
  final double price;
  final int stock;
  final ListingStatus status;
  final String? imageUrl;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Vertical tile for narrow rails (e.g. related products).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat('#,##0', 'fa').format(price);
    if (compact) {
      return _CompactListingCard(
        title: title,
        priceText: priceText,
        imageUrl: imageUrl,
        onTap: onTap,
      );
    }

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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: AppColors.secondarySoft,
                        child: Icon(Icons.image_outlined, color: AppColors.inkMuted),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RahmaniPriceText(
                          formatted: priceText,
                          symbol: AppConstants.currencySymbol,
                        ),
                        Text(
                          'موجودی $stock',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RahmaniChip(
                      label: status.labelFa,
                      tone: switch (status) {
                        ListingStatus.active => RahmaniChipTone.success,
                        ListingStatus.inactive => RahmaniChipTone.neutral,
                        ListingStatus.outOfStock => RahmaniChipTone.danger,
                      },
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactListingCard extends StatelessWidget {
  const _CompactListingCard({
    required this.title,
    required this.priceText,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final String priceText;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D212121),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMd - 1),
                  ),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.secondarySoft,
                            child: Icon(Icons.image_outlined, color: AppColors.inkMuted),
                          ),
                        )
                      : Container(
                          color: AppColors.secondarySoft,
                          child: Icon(Icons.image_outlined, color: AppColors.inkMuted),
                        ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '$priceText ${AppConstants.currencySymbol}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

