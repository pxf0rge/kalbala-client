import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/presentation/utils/category_visuals.dart';

/// Soft circular category strip with semantic icons.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    required this.categories,
    this.onCategoryTap,
    this.showSeeAll = true,
    this.maxItems = 8,
    super.key,
  });

  final List<CategorySummaryEntity> categories;
  final void Function(CategorySummaryEntity category)? onCategoryTap;
  final bool showSeeAll;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final items = maxItems != null ? categories.take(maxItems!).toList() : categories;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        child: SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length + (showSeeAll ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (showSeeAll && index == items.length) {
                return _CategoryIconButton(
                  label: 'دسته‌بندی‌ها',
                  look: CategoryLook.icon(
                    Icons.apps_rounded,
                    background: AppColors.secondarySoft,
                    foreground: AppColors.secondary,
                  ),
                  onTap: () => context.push(RouteNames.categories),
                );
              }
              final category = items[index];
              return _CategoryIconButton(
                label: category.name,
                look: CategoryVisuals.resolve(
                  name: category.name,
                  slug: category.slug,
                  iconUrl: category.iconUrl,
                ),
                onTap: () {
                  if (onCategoryTap != null) {
                    onCategoryTap!(category);
                  } else {
                    context.push(RouteNames.categoryProducts(category.id));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryIconButton extends StatelessWidget {
  const _CategoryIconButton({
    required this.label,
    required this.look,
    required this.onTap,
  });

  final String label;
  final CategoryLook look;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: look.background,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F212121),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: look.isNetwork
                  ? CachedNetworkImage(
                      imageUrl: look.networkUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Icon(
                        Icons.grid_view_rounded,
                        color: look.foreground,
                        size: 26,
                      ),
                    )
                  : Icon(look.icon, color: look.foreground, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
