import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/theme/theme_mode_provider.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/home/presentation/widgets/banners_carousel.dart';
import 'package:rahmani_project/features/home/presentation/widgets/category_grid.dart';
import 'package:rahmani_project/features/home/presentation/widgets/featured_booths_carousel.dart';
import 'package:rahmani_project/features/home/presentation/widgets/featured_products_grid.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/presentation/providers/search_provider.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/rahmani_logo_mark.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Buyer home — marketplace feed with clear visual hierarchy.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context, WidgetRef ref, [SearchTab tab = SearchTab.products]) {
    ref.read(searchFiltersProvider.notifier).prepareForTab(tab);
    context.push(RouteNames.search, extra: tab);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: feedAsync.when(
          loading: () => const SafeArea(
            child: AppLoadingIndicator(message: 'در حال آماده‌سازی بازار…'),
          ),
          error: (e, _) => SafeArea(
            child: AppErrorWidget(
              message: friendlyErrorMessage(e),
              onRetry: () => ref.read(homeFeedProvider.notifier).refresh(),
            ),
          ),
          data: (feed) {
            if (feed == null) {
              return const SafeArea(
                child: AppEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'بازار هنوز خالی است',
                  subtitle: 'فروشگاه‌ها و محصولات پس از پیکربندی نمایش داده می‌شوند.',
                ),
              );
            }

            final isEmpty = feed.featuredBooths.isEmpty &&
                feed.featuredProducts.isEmpty &&
                feed.categories.isEmpty &&
                feed.banners.isEmpty &&
                feed.newBooths.isEmpty &&
                feed.popularProducts.isEmpty &&
                feed.recentlyViewed.isEmpty;

            return Column(
              children: [
                _HomeHeader(
                  themeMode: themeMode,
                  unreadCount:
                      ref.watch(unreadNotificationCountProvider).valueOrNull ??
                          0,
                  onSearch: () => _openSearch(context, ref),
                  onNotifications: () => context.push(RouteNames.notifications),
                  onToggleTheme: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(homeFeedProvider.notifier).refresh(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        if (isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: AppEmptyState(
                              icon: Icons.explore_outlined,
                              title: 'هنوز محتوایی نیست',
                              subtitle:
                                  'فروشگاه‌ها و محصولات ویژه توسط ادمین علامت‌گذاری می‌شوند.',
                            ),
                          )
                        else ...[
                          if (feed.banners.isNotEmpty)
                            SliverToBoxAdapter(
                              child: BannersCarousel(banners: feed.banners),
                            )
                          else
                            const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          SliverToBoxAdapter(
                            child: CategoryGrid(
                              categories: feed.categories,
                              maxItems: 8,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: FeaturedProductsGrid(
                              products: _prefer(
                                feed.popularProducts,
                                feed.featuredProducts,
                              ),
                              title: 'پرفروش‌ترین‌ها',
                              subtitle: 'محبوب‌ترین‌های امروز',
                              layout: ProductSectionLayout.grid,
                              emphasis: RahmaniSectionEmphasis.high,
                              maxItems: 6,
                              animated: true,
                              onSeeAll: () => _openSearch(context, ref),
                            ),
                          ),
                          const SliverToBoxAdapter(child: _SectionBand()),
                          SliverToBoxAdapter(
                            child: FeaturedBoothsCarousel(
                              booths: feed.featuredBooths,
                              title: 'فروشگاه‌های منتخب',
                              subtitle: 'فروشندگان ویژه بازار',
                              emphasis: RahmaniSectionEmphasis.normal,
                              onSeeAll: () =>
                                  _openSearch(context, ref, SearchTab.booths),
                            ),
                          ),
                          if (feed.featuredProducts.isNotEmpty &&
                              feed.popularProducts.isNotEmpty) ...[
                            const SliverToBoxAdapter(child: _SectionBand()),
                            SliverToBoxAdapter(
                              child: FeaturedProductsGrid(
                                products: feed.featuredProducts,
                                title: 'پیشنهاد ویژه',
                                subtitle: 'انتخاب تحریریه کال بالا',
                                layout: ProductSectionLayout.grid,
                                emphasis: RahmaniSectionEmphasis.normal,
                                maxItems: 6,
                              ),
                            ),
                          ],
                          if (feed.newBooths.isNotEmpty) ...[
                            const SliverToBoxAdapter(child: _SectionBand()),
                            SliverToBoxAdapter(
                              child: FeaturedBoothsCarousel(
                                booths: feed.newBooths,
                                title: 'فروشگاه‌های تازه',
                                subtitle: 'تازه‌واردهای بازار',
                                emphasis: RahmaniSectionEmphasis.low,
                              ),
                            ),
                          ],
                          if (feed.recentlyViewed.isNotEmpty) ...[
                            const SliverToBoxAdapter(child: _SectionBand()),
                            SliverToBoxAdapter(
                              child: FeaturedProductsGrid(
                                products: feed.recentlyViewed,
                                title: 'بازدیدهای اخیر',
                                subtitle: 'ادامه از جایی که بودید',
                                layout: ProductSectionLayout.rail,
                                emphasis: RahmaniSectionEmphasis.low,
                              ),
                            ),
                          ],
                          const SliverToBoxAdapter(child: SizedBox(height: 28)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<PublicListingSummaryEntity> _prefer(
    List<PublicListingSummaryEntity> primary,
    List<PublicListingSummaryEntity> fallback,
  ) {
    return primary.isNotEmpty ? primary : fallback;
  }
}

/// Soft band separator between marketplace sections.
class _SectionBand extends StatelessWidget {
  const _SectionBand();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const SizedBox(height: AppSpacing.lg),
    );
  }
}

/// Brand row + full-width search — marketplace sticky header.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.themeMode,
    required this.unreadCount,
    required this.onSearch,
    required this.onNotifications,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final int unreadCount;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).colorScheme.surface;
    final searchFill = isDark ? const Color(0xFF252B36) : AppColors.secondarySoft;
    final iconColor = isDark ? Colors.white70 : AppColors.inkMuted;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: bg,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            bottom: BorderSide(color: AppColors.hairline.withValues(alpha: 0.7)),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: isDark ? 'حالت روشن' : 'حالت تاریک',
                        onPressed: onToggleTheme,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_outlined,
                            key: ValueKey(isDark),
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const KalBalaLogoMark(
                                size: 34,
                                useBrandAsset: true,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'کال بالا',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        height: 1.05,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'KalBala',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        height: 1.1,
                                        letterSpacing: 0.2,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'اعلان‌ها',
                        onPressed: onNotifications,
                        icon: Badge(
                          isLabelVisible: unreadCount > 0,
                          label: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(fontSize: 10),
                          ),
                          child: Icon(
                            unreadCount > 0
                                ? Icons.notifications_rounded
                                : Icons.notifications_none_rounded,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Material(
                  color: searchFill,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      height: 46,
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded, size: 22, color: iconColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'جستجوی محصول، فروشگاه یا دسته…',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: iconColor),
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
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
