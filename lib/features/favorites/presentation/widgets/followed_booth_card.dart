import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

/// Rich tile for a followed booth (cover, logo, meta, unfollow).
class FollowedBoothCard extends StatelessWidget {
  const FollowedBoothCard({
    required this.booth,
    required this.onOpen,
    required this.onUnfollow,
    this.unfollowBusy = false,
    super.key,
  });

  final FeaturedBoothEntity booth;
  final VoidCallback onOpen;
  final VoidCallback onUnfollow;
  final bool unfollowBusy;

  static final _countFormat = NumberFormat.compact(locale: 'fa');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = booth.city?.trim();
    final hasLocation = location != null && location.isNotEmpty;

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (booth.coverUrl != null && booth.coverUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: booth.coverUrl!,
                        fit: BoxFit.cover,
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.primarySoft,
                              AppColors.secondarySoft,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 40,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 0,
                      child: Transform.translate(
                        offset: const Offset(0, 22),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceRaised,
                            border: Border.all(color: AppColors.surfaceRaised, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: booth.logoUrl != null && booth.logoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: booth.logoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : ColoredBox(
                                  color: AppColors.primarySoft,
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booth.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (hasLocation) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.inkMuted,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.inkMuted,
                        ),
                      ],
                    ),
                    if (booth.description != null &&
                        booth.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        booth.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.people_outline_rounded,
                          label: '${_countFormat.format(booth.followerCount)} دنبال‌کننده',
                        ),
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.visibility_outlined,
                          label: '${_countFormat.format(booth.viewCount)} بازدید',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: unfollowBusy ? null : onUnfollow,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: unfollowBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('لغو دنبال'),
                        ),
                      ],
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
        ],
      ),
    );
  }
}
