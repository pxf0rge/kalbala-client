import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

/// Header for public booth profile page.
class BoothHeader extends StatelessWidget {
  const BoothHeader({
    required this.booth,
    this.onPhoneTap,
    super.key,
  });

  final FeaturedBoothEntity booth;
  final VoidCallback? onPhoneTap;

  @override
  Widget build(BuildContext context) {
    final phone = booth.publicPhone;
    final textTheme = Theme.of(context).textTheme;
    final countFormat = NumberFormat.decimalPattern('fa');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booth.coverUrl != null)
          CachedNetworkImage(
            imageUrl: booth.coverUrl!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        else
          Container(
            height: 120,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.storefront, size: 48),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage:
                    booth.logoUrl != null ? CachedNetworkImageProvider(booth.logoUrl!) : null,
                child: booth.logoUrl == null ? const Icon(Icons.store) : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booth.name, style: textTheme.titleLarge),
                    if (booth.city != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              booth.city!,
                              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (phone != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Material(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: InkWell(
                          onTap: onPhoneTap,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs + 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    phone,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                    textDirection: ui.TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${countFormat.format(booth.viewCount)} بازدید • '
                      '${countFormat.format(booth.followerCount)} دنبال‌کننده',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (booth.description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Text(booth.description!),
          ),
      ],
    );
  }
}
