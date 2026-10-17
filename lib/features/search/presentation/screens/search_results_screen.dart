import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/presentation/providers/search_provider.dart';
import 'package:rahmani_project/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:rahmani_project/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:rahmani_project/features/search/presentation/widgets/search_result_card.dart';
import 'package:rahmani_project/features/search/presentation/widgets/sort_selector.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Search results with filters, sort, and infinite scroll.
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final query = ref.read(searchFiltersProvider).query;
    _controller.text = query;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchResultsProvider.notifier).loadMore();
    }
  }

  void _onQueryChanged(String value) {
    ref.read(searchFiltersProvider.notifier).updateQuery(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.invalidate(searchResultsProvider);
      _recordHistory(value);
    });
  }

  Future<void> _recordHistory(String query) async {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null || query.trim().length < 2) return;
    await ref.read(searchHistoryProvider.notifier).add(query);
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    ).then((_) => ref.invalidate(searchResultsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتایج جستجو'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _controller,
              onChanged: _onQueryChanged,
              onSubmitted: _onQueryChanged,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SearchTab>(
            segments: SearchTab.values
                .map((tab) => ButtonSegment(value: tab, label: Text(tab.labelFa)))
                .toList(),
            selected: {filters.tab},
            onSelectionChanged: (selection) {
              ref.read(searchFiltersProvider.notifier).updateTab(selection.first);
              ref.invalidate(searchResultsProvider);
            },
          ),
          if (filters.tab == SearchTab.products) ...[
            const SizedBox(height: 8),
            SortSelector(
              selected: filters.sort,
              showRelevance: filters.query.trim().length >= 2,
              onSelected: (sort) {
                ref.read(searchFiltersProvider.notifier).updateSort(sort);
                ref.invalidate(searchResultsProvider);
              },
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: resultsAsync.when(
              loading: () => const AppLoadingIndicator(message: 'در حال جستجو...'),
              error: (e, _) => AppErrorWidget(
                message: friendlyErrorMessage(e),
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
              data: (page) {
                final isBooths = filters.tab == SearchTab.booths;
                final isEmpty = isBooths ? page.booths.isEmpty : page.listings.isEmpty;

                if (isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.search_off,
                    title: 'نتیجه‌ای یافت نشد',
                    subtitle: 'عبارت جستجو یا فیلترها را تغییر دهید.',
                  );
                }

                if (isBooths) {
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: page.booths.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        BoothSearchResultCard(booth: page.booths[index]),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: page.listings.length + (page.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index >= page.listings.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    return SearchResultCard(listing: page.listings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
