import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';
import 'package:rahmani_project/features/cart/presentation/widgets/quantity_selector.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/chat/presentation/providers/chat_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/utils/variant_attributes.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/listing_card.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/variant_selector.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_action.dart';
import 'package:rahmani_project/features/review/presentation/providers/review_provider.dart';
import 'package:rahmani_project/features/review/presentation/widgets/review_list.dart';
import 'package:rahmani_project/features/review/presentation/widgets/star_rating.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buyer-facing product detail for a specific booth listing.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedVariantId;
  bool _viewTracked = false;
  bool _addingToCart = false;
  int _imageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackProductView());
  }

  Future<void> _trackProductView() async {
    if (_viewTracked) return;
    _viewTracked = true;
    await ref.read(trackEventProvider).call(
          eventType: AnalyticsEventType.productView,
          entityType: 'listing',
          entityId: widget.listingId,
        );
  }

  Future<void> _share(PublicListingEntity listing) async {
    final priceFormat = NumberFormat('#,##0', 'fa');
    final text = [
      listing.productName,
      'قیمت: ${priceFormat.format(listing.price)} ${AppConstants.currencySymbol}',
      if (listing.boothName.isNotEmpty) 'فروشگاه: ${listing.boothName}',
    ].join('\n');
    await Share.share(text);
  }

  int _effectiveQuantity(int maxStock) {
    if (maxStock <= 0) return 1;
    if (_quantity > maxStock) return maxStock;
    if (_quantity < 1) return 1;
    return _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(publicListingDetailProvider(widget.listingId));
    final summaryAsync = ref.watch(listingReviewSummaryProvider(widget.listingId));
    final priceFormat = NumberFormat('#,##0', 'fa');

    final listing = listingAsync.valueOrNull;
    final selectedVariant = listing == null ? null : _resolveVariant(listing);
    final displayStock = selectedVariant?.stock ?? listing?.stock ?? 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: const Text('جزئیات محصول'),
        actions: [
          listingAsync.maybeWhen(
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'اشتراک‌گذاری',
                onPressed: () => _share(item),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          listingAsync.maybeWhen(
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return ReportIconButton(
                target: ReportTarget(
                  type: ReportTargetType.product,
                  targetId: widget.listingId,
                  label: item.productName,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          FavoriteButton(listingId: widget.listingId),
        ],
      ),
      body: listingAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(
          message: friendlyErrorMessage(e),
          onRetry: () => ref.invalidate(publicListingDetailProvider(widget.listingId)),
        ),
        data: (listing) {
          if (listing == null) {
            return const Center(child: Text('محصول یافت نشد'));
          }

          final selectedVariant = _resolveVariant(listing);
          final displayPrice = selectedVariant?.price ?? listing.price;
          final displayStock = selectedVariant?.stock ?? listing.stock;
          final quantity = _effectiveQuantity(displayStock);

          final displayComparePrice =
              selectedVariant?.compareAtPrice ?? listing.compareAtPrice;
          final hasDiscount =
              displayComparePrice != null && displayComparePrice > displayPrice;
          final discountPercent = hasDiscount
              ? ((displayComparePrice - displayPrice) / displayComparePrice * 100)
                  .round()
              : 0;
          final images = listing.productImages;
          final sku = selectedVariant?.sku ?? listing.sku;
          final attrRows = selectedVariant != null
              ? VariantAttributes.displayRows(selectedVariant.attributes)
              : const <MapEntry<String, String>>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxl,
            ),
            children: [
              if (images.isNotEmpty) ...[
                SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) => setState(() => _imageIndex = index),
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: AppColors.secondarySoft),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.secondarySoft,
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              final active = index == _imageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active ? AppColors.primary : AppColors.hairline,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(listing.productName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              if (hasDiscount) ...[
                Row(
                  children: [
                    Text(
                      '${priceFormat.format(displayComparePrice)} ${AppConstants.currencySymbol}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.inkMuted,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    RahmaniChip(
                      label: '$discountPercent٪ تخفیف',
                      tone: RahmaniChipTone.danger,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                '${priceFormat.format(displayPrice)} ${AppConstants.currencySymbol}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              summaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (summary) {
                  if (!summary.hasReviews) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: StarRatingDisplay(
                      rating: summary.averageRating,
                      reviewCount: summary.reviewCount,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(_stockLabel(displayStock)),
              if (displayStock > 0 && displayStock <= 5) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'فقط $displayStock عدد باقی مانده',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ],
              if (listing.hasVariants && listing.variants.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                VariantSelector(
                  variants: listing.variants,
                  selectedId: _selectedVariantId ?? listing.variants.first.id,
                  onSelected: (variant) => setState(() {
                    _selectedVariantId = variant.id;
                    _quantity = _effectiveQuantity(variant.stock);
                  }),
                ),
              ],
              if (displayStock > 0) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text('تعداد', style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    QuantitySelector(
                      quantity: quantity,
                      maxQuantity: displayStock,
                      onChanged: (value) => setState(() => _quantity = value),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SpecsSection(
                brand: listing.productBrand,
                weightGrams: listing.weightGrams,
                sku: sku,
                categoryName: listing.categoryName,
                attributeRows: attrRows,
              ),
              if (listing.productDescription != null &&
                  listing.productDescription!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('توضیحات', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(listing.productDescription!),
              ],
              const SizedBox(height: AppSpacing.xl),
              Material(
                color: AppColors.surfaceRaised,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: BorderSide(color: AppColors.hairline),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: listing.boothLogoUrl != null
                      ? CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(listing.boothLogoUrl!),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.storefront, color: AppColors.primary),
                        ),
                  title: Text(listing.boothName),
                  subtitle: const Text('فروشنده'),
                  trailing: Icon(Icons.chevron_left, color: AppColors.inkMuted),
                  onTap: () => context.push(RouteNames.publicBooth(listing.boothSlug)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _BoothContactActions(
                boothId: listing.boothId,
                boothSlug: listing.boothSlug,
                boothName: listing.boothName,
              ),
              const SizedBox(height: AppSpacing.xl),
              ReviewList.listing(listingId: widget.listingId),
              const SizedBox(height: AppSpacing.xl),
              _RelatedProducts(listingId: widget.listingId),
            ],
          );
        },
      ),
      bottomNavigationBar: listing == null
          ? null
          : Material(
              color: AppColors.surfaceRaised,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.hairline)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.md,
                      AppSpacing.screen,
                      AppSpacing.md,
                    ),
                    child: FilledButton(
                      onPressed: displayStock > 0 && !_addingToCart
                          ? () => _addToCart(listing, selectedVariant)
                          : null,
                      child: _addingToCart
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              displayStock > 0
                                  ? 'افزودن ${_effectiveQuantity(displayStock)} عدد به سبد'
                                  : 'ناموجود',
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  ListingVariantEntity? _resolveVariant(PublicListingEntity listing) {
    if (listing.variants.isEmpty) return null;
    final id = _selectedVariantId ?? listing.variants.first.id;
    return listing.variants.where((v) => v.id == id).firstOrNull ??
        listing.variants.first;
  }

  String _stockLabel(int stock) {
    if (stock <= 0) return 'ناموجود';
    return 'موجودی: $stock';
  }

  Future<void> _addToCart(
    PublicListingEntity listing,
    ListingVariantEntity? selectedVariant,
  ) async {
    if (listing.hasVariants && selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً یک گزینه انتخاب کنید.')),
      );
      return;
    }

    final maxStock = selectedVariant?.stock ?? listing.stock;
    final quantity = _effectiveQuantity(maxStock);
    if (quantity < 1 || quantity > maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعداد باید بین ۱ و $maxStock باشد.')),
      );
      return;
    }

    setState(() => _addingToCart = true);

    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      if (!mounted) return;
      setState(() => _addingToCart = false);
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

    final error = await ref.read(cartProvider.notifier).addToCart(
          AddToCartInput(
            listingId: listing.id,
            variantId: selectedVariant?.id,
            quantity: quantity,
          ),
        );

    if (error == null) {
      await ref.read(trackEventProvider).call(
            eventType: AnalyticsEventType.addToCart,
            entityType: 'listing',
            entityId: listing.id,
          );
    }

    if (!mounted) return;
    setState(() => _addingToCart = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? '$quantity عدد به سبد خرید اضافه شد'
              : friendlyErrorMessage(error),
        ),
        action: error != null && error.contains('وارد')
            ? SnackBarAction(
                label: 'ورود',
                onPressed: () => context.push(RouteNames.login),
              )
            : null,
      ),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  const _SpecsSection({
    required this.brand,
    required this.weightGrams,
    required this.sku,
    required this.categoryName,
    required this.attributeRows,
  });

  final String? brand;
  final int weightGrams;
  final String? sku;
  final String? categoryName;
  final List<MapEntry<String, String>> attributeRows;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (brand != null && brand!.trim().isNotEmpty) MapEntry('برند', brand!),
      if (categoryName != null && categoryName!.trim().isNotEmpty)
        MapEntry('دسته', categoryName!),
      if (weightGrams > 0) MapEntry('وزن', '$weightGrams گرم'),
      if (sku != null && sku!.trim().isNotEmpty) MapEntry('کد کالا (SKU)', sku!),
      ...attributeRows,
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مشخصات', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(color: AppColors.hairline),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.hairline),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rows[i].key,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.inkMuted,
                              ),
                        ),
                      ),
                      Text(
                        rows[i].value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal list of related products from the same category.
class _RelatedProducts extends ConsumerWidget {
  const _RelatedProducts({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedListingsProvider(listingId));

    return relatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RahmaniSectionHeader(
              title: 'محصولات مرتبط',
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = related[index];
                  return SizedBox(
                    width: 148,
                    child: ListingCard.fromPublic(
                      item,
                      compact: true,
                      onTap: () => context.push(RouteNames.productDetail(item.id)),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BoothContactActions extends ConsumerWidget {
  const _BoothContactActions({
    required this.boothId,
    required this.boothSlug,
    required this.boothName,
  });

  final String boothId;
  final String boothSlug;
  final String boothName;

  Future<void> _call(BuildContext context, String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final ok = await launchUrl(Uri(scheme: 'tel', path: cleaned));
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان برقراری تماس وجود ندارد')),
      );
    }
  }

  Future<void> _chat(BuildContext context, WidgetRef ref) async {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      context.push(RouteNames.login);
      return;
    }
    final result = await ref.read(startConversationProvider).call(boothId);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (conversationId) {
        ref.invalidate(conversationsProvider);
        context.push(RouteNames.chatDetail(conversationId), extra: boothName);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boothAsync = ref.watch(publicBoothProvider(boothSlug));
    final phone = boothAsync.valueOrNull?.publicPhone;

    return Row(
      children: [
        if (phone != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _call(context, phone),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('تماس'),
            ),
          ),
        if (phone != null) const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _chat(context, ref),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('گفتگو'),
          ),
        ),
      ],
    );
  }
}