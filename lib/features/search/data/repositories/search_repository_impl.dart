import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/data/models/home_models.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/search/data/datasources/search_remote_datasource_impl.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';
import 'package:rahmani_project/features/search/domain/repositories/search_repository.dart';

final class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remote);

  final SearchRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> searchListings({
    required SearchFilters filters,
    required int limit,
    required int offset,
  }) async {
    try {
      final data = await _remote.fetchListings(filters: filters, limit: limit, offset: offset);
      final models = data
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> searchBooths({
    required String query,
    required int limit,
    required int offset,
  }) async {
    try {
      final data = await _remote.fetchBooths(query: query, limit: limit, offset: offset);
      final models = data
          .map((row) => FeaturedBoothModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SearchHistoryEntry>>> getMyHistory({int limit = 15}) async {
    try {
      final entries = await _remote.fetchMyHistory(limit: limit);
      return Right(entries);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> addHistory(String query) async {
    try {
      await _remote.addHistory(query);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await _remote.clearHistory();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeHistoryEntry(String entryId) async {
    try {
      await _remote.removeHistoryEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PopularSearchEntry>>> getPopularSearches({int limit = 10}) async {
    try {
      final entries = await _remote.fetchPopularSearches(limit: limit);
      return Right(entries);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SearchSuggestion>>> getSuggestions({
    required String query,
    int limit = 8,
    String kind = 'all',
  }) async {
    try {
      final entries = await _remote.fetchSuggestions(
        query: query,
        limit: limit,
        kind: kind,
      );
      return Right(entries);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredSearchRepository implements SearchRepository {
  const UnconfiguredSearchRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> searchListings({
    required SearchFilters filters,
    required int limit,
    required int offset,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> searchBooths({
    required String query,
    required int limit,
    required int offset,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<SearchHistoryEntry>>> getMyHistory({int limit = 15}) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> addHistory(String query) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> clearHistory() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> removeHistoryEntry(String entryId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<PopularSearchEntry>>> getPopularSearches({int limit = 10}) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<SearchSuggestion>>> getSuggestions({
    required String query,
    int limit = 8,
    String kind = 'all',
  }) async =>
      const Left(AuthFailure(_message));
}
