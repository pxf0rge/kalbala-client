import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-bleed marketplace banner carousel with CTA overlay.
class BannersCarousel extends StatefulWidget {
  const BannersCarousel({required this.banners, super.key});

  final List<BannerEntity> banners;

  @override
  State<BannersCarousel> createState() => _BannersCarouselState();
}

class _BannersCarouselState extends State<BannersCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_pageController.hasClients) return;
        final next = (_current + 1) % widget.banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _open(BannerEntity banner) async {
    switch (banner.linkType) {
      case 'listing':
        if (banner.linkTargetId != null) {
          context.push(RouteNames.productDetail(banner.linkTargetId!));
        }
        break;
      case 'category':
        if (banner.linkTargetId != null) {
          context.push(RouteNames.categoryProducts(banner.linkTargetId!));
        }
        break;
      case 'booth':
        if (banner.linkTargetId != null && SupabaseConfig.isInitialized) {
          final data = await SupabaseConfig.client
              .from('booths')
              .select('slug')
              .eq('id', banner.linkTargetId!)
              .maybeSingle();
          final slug = data?['slug'] as String?;
          if (slug != null && mounted) {
            context.push(RouteNames.publicBooth(slug));
          }
        }
        break;
      case 'external':
        final url = banner.linkUrl;
        if (url != null) {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 188,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (index) => setState(() => _current = index),
              padEnds: true,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                final active = index == _current;
                return AnimatedScale(
                  scale: active ? 1 : 0.92,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Material(
                      color: AppColors.primary,
                      elevation: 0,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _open(banner),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (banner.imageUrl.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    const ColoredBox(color: AppColors.primary),
                                errorWidget: (_, _, _) => const ColoredBox(
                                  color: AppColors.primary,
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.white54,
                                    size: 36,
                                  ),
                                ),
                              )
                            else
                              const ColoredBox(color: AppColors.primary),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    Color(0xCC0A4D3C),
                                    Color(0x660A4D3C),
                                    Color(0x140A4D3C),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 200),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        banner.title.isNotEmpty
                                            ? banner.title
                                            : 'خرید آسان، تجربه بهتر',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              height: 1.25,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'هزاران محصول با بهترین قیمت',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 14),
                                      Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(22),
                                        child: InkWell(
                                          onTap: () => _open(banner),
                                          borderRadius: BorderRadius.circular(22),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'مشاهده',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_back_ios_new_rounded,
                                                  size: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.banners.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) {
                final active = index == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.hairline.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
