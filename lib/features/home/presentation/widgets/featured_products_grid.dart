import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

enum ProductSectionLayout { grid, rail }

/// Marketplace product section — denser cards with shared section header.
class FeaturedProductsGrid extends StatelessWidget {
  const FeaturedProductsGrid({
    required this.products,
    this.title = 'محصولات ویژه',
    this.subtitle,
    this.layout = ProductSectionLayout.grid,
    this.emphasis = RahmaniSectionEmphasis.normal,
    this.maxItems = 6,
    this.onSeeAll,
    this.animated = false,
    super.key,
  });

  final List<PublicListingSummaryEntity> products;
  final String title;
  final String? subtitle;
  final ProductSectionLayout layout;
  final RahmaniSectionEmphasis emphasis;
  final int maxItems;
  final VoidCallback? onSeeAll;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final priceFormat = NumberFormat('#,##0', 'fa');
    final visible = layout == ProductSectionLayout.grid
        ? products.take(maxItems).toList()
        : products;

    Widget body = ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RahmaniSectionHeader(
            title: title,
            subtitle: subtitle,
            emphasis: emphasis,
            actionLabel: onSeeAll != null ? 'مشاهده همه' : null,
            onAction: onSeeAll,
          ),
          if (layout == ProductSectionLayout.grid)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 10.0;
                  final tileWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final product in visible)
                        SizedBox(
                          width: tileWidth,
                          child: _ProductCard(
                            product: product,
                            priceFormat: priceFormat,
                            onTap: () =>
                                context.push(RouteNames.productDetail(product.id)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            )
          else
            SizedBox(
              height: 148 + _ProductCard.footerHeight + AppSpacing.lg,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.lg,
                ),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final product = visible[index];
                  return SizedBox(
                    width: 148,
                    child: _ProductCard(
                      product: product,
                      priceFormat: priceFormat,
                      onTap: () =>
                          context.push(RouteNames.productDetail(product.id)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

    if (!animated) return body;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 12),
          child: child,
        ),
      ),
      child: body,
    );
  }
}

class _ProductCard extends ConsumerStatefulWidget {
  const _ProductCard({
    required this.product,
    required this.priceFormat,
    required this.onTap,
  });

  final PublicListingSummaryEntity product;
  final NumberFormat priceFormat;
  final VoidCallback onTap;

  /// Fixed footer so long titles never push the price out of the card.
  static const double footerHeight = 112;

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  bool _adding = false;

  int? get _discountPercent {
    if (!widget.product.hasDiscount) return null;
    final compare = widget.product.compareAtPrice!;
    if (compare <= 0) return null;
    return (((compare - widget.product.price) / compare) * 100)
        .round()
        .clamp(1, 99);
  }

  /// Stable decorative rating until listing ratings ship in the feed.
  ({double rating, int count}) get _displayRating {
    final seed = widget.product.id.hashCode.abs();
    final rating = 4.2 + ((seed % 8) / 10);
    final count = 40 + (seed % 180);
    return (rating: double.parse(rating.toStringAsFixed(1)), count: count);
  }

  Future<void> _addToCart() async {
    if (_adding) return;
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('برای افزودن به سبد ابتدا وارد حساب شوید.'),
          action: SnackBarAction(
            label: 'ورود',
            onPressed: () => context.push(RouteNames.login),
          ),
        ),
      );
      return;
    }

    setState(() => _adding = true);
    final error = await ref.read(cartProvider.notifier).addToCart(
          AddToCartInput(listingId: widget.product.id),
        );
    if (!mounted) return;
    setState(() => _adding = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'به سبد خرید اضافه شد'),
        action: error == null
            ? SnackBarAction(
                label: 'سبد',
                onPressed: () => context.push(RouteNames.cart),
              )
            : SnackBarAction(
                label: 'جزئیات',
                onPressed: () =>
                    context.push(RouteNames.productDetail(widget.product.id)),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceFormat = widget.priceFormat;
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    final surface = Theme.of(context).colorScheme.surface;
    final discount = _discountPercent;
    final textTheme = Theme.of(context).textTheme;
    final rating = _displayRating;

    return Material(
      color: surface,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: radius,
            border: Border.all(color: AppColors.hairline.withValues(alpha: 0.8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F212121),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RahmaniNetworkImage(
                      url: product.primaryImage,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusMd - 1),
                      ),
                    ),
                    if (discount != null)
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: Text(
                            '$discount%',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: FavoriteButton(
                        listingId: product.id,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: _ProductCard.footerHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.boothName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          product.boothName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF5A524),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${rating.rating}',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            ' (${NumberFormat('#,##0', 'fa').format(rating.count)})',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (product.hasDiscount)
                                  Text(
                                    '${priceFormat.format(product.compareAtPrice)} '
                                    '${AppConstants.currencySymbol}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelSmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.inkMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                RahmaniPriceText(
                                  formatted: priceFormat.format(product.price),
                                  symbol: AppConstants.currencySymbol,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: _adding ? null : _addToCart,
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: _adding
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                              ),
                            ),
                          ),
                        ],
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
