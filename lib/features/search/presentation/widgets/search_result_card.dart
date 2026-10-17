import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Card for a listing search result.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({required this.listing, super.key});

  final PublicListingSummaryEntity listing;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push(RouteNames.productDetail(listing.id)),
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
                child: listing.primaryImage != null
                    ? CachedNetworkImage(
                        imageUrl: listing.primaryImage!,
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
                      listing.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (listing.boothName != null) ...[
                      const SizedBox(height: 4),
                      Text(listing.boothName!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: 8),
                    RahmaniPriceText(
                      formatted: priceFormat.format(listing.price),
                      symbol: AppConstants.currencySymbol,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for a booth search result.
class BoothSearchResultCard extends StatelessWidget {
  const BoothSearchResultCard({required this.booth, super.key});

  final FeaturedBoothEntity booth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push(RouteNames.publicBooth(booth.slug)),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.secondarySoft,
                backgroundImage:
                    booth.logoUrl != null ? CachedNetworkImageProvider(booth.logoUrl!) : null,
                child: booth.logoUrl == null
                    ? Icon(Icons.storefront, color: AppColors.inkMuted)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booth.name, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      booth.city ?? booth.slug,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
