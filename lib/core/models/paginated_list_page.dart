import 'package:rahmani_project/core/constants/pagination_constants.dart';

/// Generic paginated list state used by Riverpod notifiers.
class PaginatedListPage<T> {
  const PaginatedListPage({
    required this.items,
    required this.hasMore,
    required this.offset,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final bool hasMore;
  final int offset;
  final bool isLoadingMore;

  static const pageSize = PaginationConstants.defaultPageSize;

  PaginatedListPage<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? offset,
    bool? isLoadingMore,
  }) {
    return PaginatedListPage<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Returns true when the scroll position is near the end of the list.
bool shouldLoadMoreFromScroll({
  required double pixels,
  required double maxScrollExtent,
  double threshold = PaginationConstants.loadMoreScrollThreshold,
}) {
  return pixels >= maxScrollExtent - threshold;
}

/// Whether another page is likely available based on the last fetch size.
bool hasMoreItems({
  required int fetchedCount,
  int pageSize = PaginationConstants.defaultPageSize,
}) {
  return fetchedCount >= pageSize;
}
