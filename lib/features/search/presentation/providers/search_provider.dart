import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/search/data/datasources/search_remote_datasource_impl.dart';
import 'package:rahmani_project/features/search/data/repositories/search_repository_impl.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/domain/repositories/search_repository.dart';
import 'package:rahmani_project/features/search/domain/usecases/search_usecases.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return SearchRemoteDataSourceImpl(SupabaseConfig.client);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final remote = ref.watch(searchRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredSearchRepository();
  return SearchRepositoryImpl(remote);
});

final searchListingsProvider = Provider((ref) => SearchListings(ref.watch(searchRepositoryProvider)));
final searchBoothsProvider = Provider((ref) => SearchBooths(ref.watch(searchRepositoryProvider)));
final getMySearchHistoryProvider =
    Provider((ref) => GetMySearchHistory(ref.watch(searchRepositoryProvider)));
final addSearchHistoryProvider =
    Provider((ref) => AddSearchHistory(ref.watch(searchRepositoryProvider)));
final clearSearchHistoryProvider =
    Provider((ref) => ClearSearchHistory(ref.watch(searchRepositoryProvider)));
final removeSearchHistoryEntryProvider =
    Provider((ref) => RemoveSearchHistoryEntry(ref.watch(searchRepositoryProvider)));
final getPopularSearchesProvider =
    Provider((ref) => GetPopularSearches(ref.watch(searchRepositoryProvider)));
final getSearchSuggestionsProvider =
    Provider((ref) => GetSearchSuggestions(ref.watch(searchRepositoryProvider)));

final searchFiltersProvider = NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void updateQuery(String query) => state = state.copyWith(query: query);

  void updateSort(SearchSortOption sort) => state = state.copyWith(sort: sort);

  void updateTab(SearchTab tab) => state = state.copyWith(tab: tab);

  /// Opens search focused on products or booths (clears query, keeps nothing else).
  void prepareForTab(SearchTab tab) {
    state = SearchFilters(tab: tab);
  }

  void applyFilters({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? boothId,
  }) {
    state = SearchFilters(
      query: state.query,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      boothId: boothId,
      sort: state.sort,
      tab: state.tab,
    );
  }

  void clearFilters() {
    state = SearchFilters(query: state.query, sort: state.sort, tab: state.tab);
  }

  void reset() => state = const SearchFilters();
}

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<SearchHistoryEntry>>(
  SearchHistoryNotifier.new,
);

class SearchHistoryNotifier extends AsyncNotifier<List<SearchHistoryEntry>> {
  @override
  Future<List<SearchHistoryEntry>> build() async {
    final result = await ref.read(getMySearchHistoryProvider).call();
    return result.fold((_) => <SearchHistoryEntry>[], (entries) => entries);
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    await ref.read(addSearchHistoryProvider).call(trimmed);
    final current = state.valueOrNull ?? [];
    final filtered = current.where((e) => e.query.toLowerCase() != trimmed.toLowerCase()).toList();
    state = AsyncData(
      [
        SearchHistoryEntry(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          query: trimmed,
          createdAt: DateTime.now(),
        ),
        ...filtered,
      ],
    );
  }

  Future<void> remove(String entryId) async {
    await ref.read(removeSearchHistoryEntryProvider).call(entryId);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((e) => e.id != entryId).toList());
  }

  Future<void> clearAll() async {
    await ref.read(clearSearchHistoryProvider).call();
    state = const AsyncData([]);
  }
}

final popularSearchesProvider =
    FutureProvider<List<PopularSearchEntry>>((ref) async {
  final result = await ref.read(getPopularSearchesProvider).call();
  return result.fold((_) => <PopularSearchEntry>[], (entries) => entries);
});

/// Live typeahead suggestions for the current query (≥2 chars).
final searchSuggestionsProvider =
    FutureProvider.autoDispose<List<SearchSuggestion>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final query = filters.query.trim();
  if (query.length < 2) return const [];

  final kind = switch (filters.tab) {
    SearchTab.booths => 'booths',
    SearchTab.products => 'products',
  };

  final result = await ref.read(getSearchSuggestionsProvider).call(
        query: query,
        kind: kind,
      );
  return result.fold((_) => <SearchSuggestion>[], (items) => items);
});

final searchResultsProvider = AsyncNotifierProvider<SearchResultsNotifier, SearchResultsPage>(
  SearchResultsNotifier.new,
);

class SearchResultsNotifier extends AsyncNotifier<SearchResultsPage> {
  @override
  Future<SearchResultsPage> build() async {
    ref.listen(searchFiltersProvider, (previous, next) {
      if (previous != next) {
        ref.invalidateSelf();
      }
    });
    return _fetchPage(offset: 0, append: false);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final nextPage = await _fetchPage(offset: current.offset, append: true);
    state = AsyncData(
      SearchResultsPage(
        listings: [...current.listings, ...nextPage.listings],
        booths: [...current.booths, ...nextPage.booths],
        hasMore: nextPage.hasMore,
        offset: nextPage.offset,
      ),
    );
  }

  Future<SearchResultsPage> _fetchPage({required int offset, required bool append}) async {
    final filters = ref.read(searchFiltersProvider);

    if (filters.tab == SearchTab.booths) {
      final result = await ref.read(searchBoothsProvider).call(
            query: filters.query,
            offset: offset,
          );
      final booths = result.fold((_) => <FeaturedBoothEntity>[], (b) => b);
      return SearchResultsPage(
        listings: const [],
        booths: booths,
        hasMore: booths.length >= SearchResultsPage.pageSize,
        offset: offset + booths.length,
      );
    }

    final result = await ref.read(searchListingsProvider).call(
          filters: filters,
          offset: offset,
        );
    final listings = result.fold((_) => <PublicListingSummaryEntity>[], (l) => l);
    return SearchResultsPage(
      listings: listings,
      booths: const [],
      hasMore: listings.length >= SearchResultsPage.pageSize,
      offset: offset + listings.length,
    );
  }
}
