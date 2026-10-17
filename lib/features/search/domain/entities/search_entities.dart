import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';

class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.boothId,
    this.sort = SearchSortOption.relevance,
    this.tab = SearchTab.products,
  });

  final String query;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? boothId;
  final SearchSortOption sort;
  final SearchTab tab;

  bool get hasActiveFilters =>
      categoryId != null || minPrice != null || maxPrice != null || boothId != null;

  SearchFilters copyWith({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? boothId,
    SearchSortOption? sort,
    SearchTab? tab,
    bool clearCategoryId = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearBoothId = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      boothId: clearBoothId ? null : (boothId ?? this.boothId),
      sort: sort ?? this.sort,
      tab: tab ?? this.tab,
    );
  }
}

class SearchResultsPage {
  const SearchResultsPage({
    required this.listings,
    required this.booths,
    required this.hasMore,
    required this.offset,
  });

  final List<PublicListingSummaryEntity> listings;
  final List<FeaturedBoothEntity> booths;
  final bool hasMore;
  final int offset;

  static const pageSize = 20;
}

/// One entry of the current user's search history.
class SearchHistoryEntry {
  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  final String id;
  final String query;
  final DateTime createdAt;
}

/// Aggregated popular search term shown as a suggestion.
class PopularSearchEntry {
  const PopularSearchEntry({
    required this.query,
    required this.count,
  });

  final String query;
  final int count;
}

/// Live typeahead suggestion from products, booths, categories, or history.
enum SearchSuggestionType { product, booth, category, history }

class SearchSuggestion {
  const SearchSuggestion({
    required this.type,
    required this.label,
    required this.queryText,
    this.subtitle,
    this.targetId,
  });

  final SearchSuggestionType type;
  final String label;
  final String queryText;
  final String? subtitle;
  final String? targetId;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    final rawType = json['suggestion_type']?.toString() ?? 'product';
    final type = switch (rawType) {
      'booth' => SearchSuggestionType.booth,
      'category' => SearchSuggestionType.category,
      'history' => SearchSuggestionType.history,
      _ => SearchSuggestionType.product,
    };
    return SearchSuggestion(
      type: type,
      label: json['label']?.toString() ?? '',
      queryText: json['query_text']?.toString() ?? json['label']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      targetId: json['target_id']?.toString(),
    );
  }
}
