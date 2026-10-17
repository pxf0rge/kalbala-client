import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SearchRemoteDataSource {
  Future<List<dynamic>> fetchListings({
    required SearchFilters filters,
    required int limit,
    required int offset,
  });

  Future<List<dynamic>> fetchBooths({
    required String query,
    required int limit,
    required int offset,
  });

  Future<List<SearchHistoryEntry>> fetchMyHistory({int limit = 15});

  Future<void> addHistory(String query);

  Future<void> clearHistory();

  Future<void> removeHistoryEntry(String entryId);

  Future<List<PopularSearchEntry>> fetchPopularSearches({int limit = 10});

  Future<List<SearchSuggestion>> fetchSuggestions({
    required String query,
    int limit = 8,
    String kind = 'all',
  });
}

final class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<dynamic>> fetchListings({
    required SearchFilters filters,
    required int limit,
    required int offset,
  }) async {
    try {
      final data = await _client.rpc(
        'search_listings',
        params: {
          'p_query': filters.query.trim().isEmpty ? null : filters.query.trim(),
          'p_category_id': filters.categoryId,
          'p_min_price': filters.minPrice,
          'p_max_price': filters.maxPrice,
          'p_booth_id': filters.boothId,
          'p_sort_by': filters.sort.dbValue,
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchBooths({
    required String query,
    required int limit,
    required int offset,
  }) async {
    try {
      final data = await _client.rpc(
        'search_booths',
        params: {
          'p_query': query.trim().isEmpty ? null : query.trim(),
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<SearchHistoryEntry>> fetchMyHistory({int limit = 15}) async {
    try {
      final data = await _client.rpc('get_my_search_history', params: {'p_limit': limit});
      final rows = data as List<dynamic>? ?? [];
      return rows.whereType<Map<String, dynamic>>().map((row) {
        return SearchHistoryEntry(
          id: row['id'] as String,
          query: row['query'] as String? ?? '',
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> addHistory(String query) async {
    try {
      await _client.rpc('add_search_history', params: {'p_query': query.trim()});
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _client.rpc('clear_search_history');
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> removeHistoryEntry(String entryId) async {
    try {
      await _client.from('search_history').delete().eq('id', entryId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PopularSearchEntry>> fetchPopularSearches({int limit = 10}) async {
    try {
      final data = await _client.rpc('get_popular_searches', params: {'p_limit': limit});
      final rows = data as List<dynamic>? ?? [];
      return rows.whereType<Map<String, dynamic>>().map((row) {
        return PopularSearchEntry(
          query: row['query'] as String? ?? '',
          count: (row['search_count'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<SearchSuggestion>> fetchSuggestions({
    required String query,
    int limit = 8,
    String kind = 'all',
  }) async {
    try {
      final data = await _client.rpc(
        'get_search_suggestions',
        params: {
          'p_query': query.trim(),
          'p_limit': limit,
          'p_kind': kind,
        },
      );
      final rows = data as List<dynamic>? ?? [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(SearchSuggestion.fromJson)
          .where((s) => s.label.trim().isNotEmpty)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
