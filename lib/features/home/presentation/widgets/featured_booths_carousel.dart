import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Horizontal store cards — distinct from category circles.
class FeaturedBoothsCarousel extends StatelessWidget {
  const FeaturedBoothsCarousel({
    required this.booths,
    this.title = 'فروشگاه‌های ویژه',
    this.subtitle,
    this.emphasis = RahmaniSectionEmphasis.normal,
    this.onSeeAll,
    super.key,
  });

  final List<FeaturedBoothEntity> booths;
  final String title;
  final String? subtitle;
  final RahmaniSectionEmphasis emphasis;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (booths.isEmpty) return const SizedBox.shrink();

    final countFormat = NumberFormat.decimalPattern('fa');

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RahmaniSectionHeader(
            title: title,
            subtitle: subtitle,
            emphasis: emphasis,
            actionLabel: onSeeAll != null ? 'همه' : null,
            onAction: onSeeAll,
          ),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              itemCount: booths.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final booth = booths[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 280 + (index * 40).clamp(0, 200)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset((1 - value) * 16, 0),
                      child: child,
                    ),
                  ),
                  child: _BoothCard(
                    booth: booth,
                    countFormat: countFormat,
                    onTap: () => context.push(RouteNames.publicBooth(booth.slug)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BoothCard extends StatelessWidget {
  const _BoothCard({
    required this.booth,
    required this.countFormat,
    required this.onTap,
  });

  final FeaturedBoothEntity booth;
  final NumberFormat countFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusMd);

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          width: 152,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusMd - 1),
                      ),
                      child: booth.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: booth.coverUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) =>
                                  ColoredBox(color: AppColors.primarySoft),
                            )
                          : ColoredBox(color: AppColors.primarySoft),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 0,
                      child: Transform.translate(
                        offset: const Offset(0, 18),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.hairline, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14212121),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: booth.logoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: booth.logoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booth.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (booth.city != null && booth.city!.isNotEmpty) booth.city!,
                        '${countFormat.format(booth.viewCount)} بازدید',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
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
