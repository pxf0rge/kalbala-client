/// Sort options for search results.
enum SearchSortOption {
  relevance,
  priceAsc,
  priceDesc,
  newest;

  String get dbValue => switch (this) {
        SearchSortOption.relevance => 'relevance',
        SearchSortOption.priceAsc => 'price_asc',
        SearchSortOption.priceDesc => 'price_desc',
        SearchSortOption.newest => 'newest',
      };

  String get labelFa => switch (this) {
        SearchSortOption.relevance => 'مرتبط‌ترین',
        SearchSortOption.priceAsc => 'ارزان‌ترین',
        SearchSortOption.priceDesc => 'گران‌ترین',
        SearchSortOption.newest => 'جدیدترین',
      };

  static SearchSortOption fromDb(String value) {
    return switch (value) {
      'price_asc' => SearchSortOption.priceAsc,
      'price_desc' => SearchSortOption.priceDesc,
      'newest' => SearchSortOption.newest,
      _ => SearchSortOption.relevance,
    };
  }
}

/// Search tab: products or booths.
enum SearchTab {
  products,
  booths;

  String get labelFa => switch (this) {
        SearchTab.products => 'محصولات',
        SearchTab.booths => 'فروشگاه‌ها',
      };
}
