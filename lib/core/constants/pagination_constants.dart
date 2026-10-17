/// Shared pagination defaults for list screens and RPC calls.
abstract final class PaginationConstants {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int chatMessagePageSize = 50;
  static const double loadMoreScrollThreshold = 200;
}
