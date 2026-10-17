import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/home/presentation/utils/category_visuals.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/presentation/providers/search_provider.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Full category discovery — KalBala «جستجوی بازار» mock layout.
class CategoryBrowseScreen extends ConsumerStatefulWidget {
  const CategoryBrowseScreen({super.key});

  @override
  ConsumerState<CategoryBrowseScreen> createState() =>
      _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends ConsumerState<CategoryBrowseScreen> {
  SearchTab _activeTab = SearchTab.products;

  void _openSearch(SearchTab tab) {
    setState(() => _activeTab = tab);
    ref.read(searchFiltersProvider.notifier).prepareForTab(tab);
    context.push(RouteNames.search, extra: tab);
  }

  @override
  Widget build(BuildContext context) {
    final rootsAsync = ref.watch(childCategoriesProvider(null));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: rootsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => AppErrorWidget(
            message: friendlyErrorMessage(e),
            onRetry: () => ref.invalidate(childCategoriesProvider(null)),
          ),
          data: (roots) {
            return RefreshIndicator(
              color: AppColors.primary,
              edgeOffset: 120,
              onRefresh: () async {
                ref.invalidate(childCategoriesProvider(null));
                await ref.read(childCategoriesProvider(null).future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _MarketSearchHeader(
                          onSearchTap: () => _openSearch(_activeTab),
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SearchModeChip(
                                  label: 'جستجوی محصول',
                                  icon: Icons.description_outlined,
                                  selected: _activeTab == SearchTab.products,
                                  onTap: () => _openSearch(SearchTab.products),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SearchModeChip(
                                  label: 'جستجوی فروشگاه',
                                  icon: Icons.storefront_outlined,
                                  selected: _activeTab == SearchTab.booths,
                                  onTap: () => _openSearch(SearchTab.booths),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (roots.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        icon: Icons.grid_view_outlined,
                        title: 'دسته‌بندی‌ای نیست',
                        subtitle: 'پس از افزودن دسته‌ها اینجا دیده می‌شوند.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      sliver: SliverList.separated(
                        itemCount: roots.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _CategoryTreeTile(category: roots[index]);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MarketSearchHeader extends StatelessWidget {
  const _MarketSearchHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, topInset + 12, 12, 48),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF0E5C48),
                AppColors.primary,
                Color(0xFF06382C),
              ],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جستجوی بازار',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'دسته‌بندی محصولات و جستجوی سریع',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/branding/search_hero.png',
                height: 118,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -26,
          child: Material(
            color: Colors.white,
            elevation: 6,
            shadowColor: const Color(0x22000000),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.inkMuted.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'جستجوی محصول، فروشگاه یا برند...',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchModeChip extends StatelessWidget {
  const _SearchModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE6F4EF) : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.hairline,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected ? AppColors.primary : AppColors.ink,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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

class _CategoryTreeTile extends ConsumerStatefulWidget {
  const _CategoryTreeTile({required this.category});

  final CategorySummaryEntity category;

  @override
  ConsumerState<_CategoryTreeTile> createState() => _CategoryTreeTileState();
}

class _CategoryTreeTileState extends ConsumerState<_CategoryTreeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = _expanded
        ? ref.watch(childCategoriesProvider(widget.category.id))
        : null;
    final look = CategoryVisuals.resolve(
      name: widget.category.name,
      slug: widget.category.slug,
      iconUrl: widget.category.iconUrl,
    );

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      shadowColor: const Color(0x14000000),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F212121),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () =>
                  context.push(RouteNames.categoryProducts(widget.category.id)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: look.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: look.isNetwork
                          ? CachedNetworkImage(
                              imageUrl: look.networkUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(look.icon, color: look.foreground, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'مشاهده محصولات',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _expanded ? 'بستن زیردسته‌ها' : 'زیردسته‌ها',
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.inkMuted.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              childrenAsync!.when(
                loading: () => const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    friendlyErrorMessage(e),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ),
                data: (children) {
                  if (children.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        'زیردسته‌ای ثبت نشده',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Divider(height: 1, color: AppColors.hairline.withValues(alpha: 0.8)),
                      for (final child in children)
                        ListTile(
                          contentPadding: const EdgeInsetsDirectional.only(
                            start: 72,
                            end: 12,
                          ),
                          title: Text(child.name),
                          trailing: Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.inkMuted,
                          ),
                          onTap: () =>
                              context.push(RouteNames.categoryProducts(child.id)),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
