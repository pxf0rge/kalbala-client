import 'dart:async';

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
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Products in a category with subcategories, filters, sort, scoped search.
class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(categoryListingsProvider(widget.categoryId).notifier).loadMore();
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final current = ref.read(categoryListingsProvider(widget.categoryId)).valueOrNull
              ?.filters ??
          const CategoryBrowseFilters();
      ref.read(categoryListingsProvider(widget.categoryId).notifier).applyFilters(
            current.copyWith(query: value),
          );
    });
  }

  Future<void> _showPriceFilter(CategoryBrowseFilters current) async {
    final notifier =
        ref.read(categoryListingsProvider(widget.categoryId).notifier);
    final minCtrl = TextEditingController(
      text: current.minPrice?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: current.maxPrice?.toStringAsFixed(0) ?? '',
    );

    final applied = await showModalBottomSheet<CategoryBrowseFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('فیلتر قیمت', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'حداقل قیمت',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'حداکثر قیمت',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        current.copyWith(clearMinPrice: true, clearMaxPrice: true),
                      ),
                      child: const Text('پاک کردن'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          current.copyWith(
                            minPrice: double.tryParse(minCtrl.text),
                            maxPrice: double.tryParse(maxCtrl.text),
                            clearMinPrice: minCtrl.text.trim().isEmpty,
                            clearMaxPrice: maxCtrl.text.trim().isEmpty,
                          ),
                        );
                      },
                      child: const Text('اعمال'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    minCtrl.dispose();
    maxCtrl.dispose();
    if (applied != null) {
      await notifier.applyFilters(applied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(categoryListingsProvider(widget.categoryId));
    final childrenAsync = ref.watch(childCategoriesProvider(widget.categoryId));
    final filters = listingsAsync.valueOrNull?.filters ?? const CategoryBrowseFilters();
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Scaffold(
      appBar: AppBar(
        title: const Text('محصولات دسته'),
        actions: [
          IconButton(
            tooltip: 'فیلتر قیمت',
            onPressed: () => _showPriceFilter(filters),
            icon: Badge(
              isLabelVisible: filters.minPrice != null || filters.maxPrice != null,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'جستجو داخل این دسته…',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surfaceRaised,
              ),
            ),
          ),
          const SizedBox(height: 8),
          childrenAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (children) {
              if (children.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: const Text('همه'),
                        selected: filters.selectedChildId == null,
                        onSelected: (_) {
                          ref
                              .read(categoryListingsProvider(widget.categoryId).notifier)
                              .applyFilters(
                                filters.copyWith(clearSelectedChildId: true),
                              );
                        },
                      ),
                    ),
                    for (final child in children)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(child.name),
                          selected: filters.selectedChildId == child.id,
                          onSelected: (_) {
                            ref
                                .read(
                                  categoryListingsProvider(widget.categoryId).notifier,
                                )
                                .applyFilters(
                                  filters.copyWith(selectedChildId: child.id),
                                );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: CategorySortOption.values.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(option.labelFa),
                    selected: filters.sort == option,
                    onSelected: (_) {
                      ref
                          .read(categoryListingsProvider(widget.categoryId).notifier)
                          .applyFilters(filters.copyWith(sort: option));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: listingsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(
                message: friendlyErrorMessage(e),
                onRetry: () => ref
                    .read(categoryListingsProvider(widget.categoryId).notifier)
                    .refresh(),
              ),
              data: (page) {
                if (page.listings.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'محصولی یافت نشد',
                    subtitle: 'فیلتر یا عبارت جستجو را تغییر دهید.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref
                      .read(categoryListingsProvider(widget.categoryId).notifier)
                      .refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: page.listings.length + (page.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index >= page.listings.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final listing = page.listings[index];
                      return Card(
                        child: ListTile(
                          leading: listing.primaryImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: listing.primaryImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_outlined),
                          title: Text(listing.productName),
                          subtitle: Text(
                            '${priceFormat.format(listing.price)} ${AppConstants.currencySymbol}'
                            '${listing.boothName != null ? ' • ${listing.boothName}' : ''}',
                          ),
                          onTap: () =>
                              context.push(RouteNames.productDetail(listing.id)),
                        ),
                      );
                    },
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