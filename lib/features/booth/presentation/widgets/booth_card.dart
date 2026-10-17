import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';

/// Summary card for a seller booth.
class BoothCard extends StatelessWidget {
  const BoothCard({
    required this.booth,
    this.onTap,
    super.key,
  });

  final BoothEntity booth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 128,
                child: booth.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: booth.coverUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.secondarySoft,
                        child: Icon(Icons.storefront, size: 48, color: AppColors.inkMuted),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondarySoft,
                      backgroundImage:
                          booth.logoUrl != null ? CachedNetworkImageProvider(booth.logoUrl!) : null,
                      child: booth.logoUrl == null
                          ? Icon(Icons.store, color: AppColors.inkMuted)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booth.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            booth.ownershipType.labelFa,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    VerificationStatusBadge(status: booth.approvalStatus),
                  ],
                ),
              ),
              if (!booth.isActive || booth.isRentalExpired)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Text(
                    booth.isRentalExpired
                        ? 'اجاره منقضی شده — فروشگاه غیرفعال است'
                        : 'فروشگاه غیرفعال',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
