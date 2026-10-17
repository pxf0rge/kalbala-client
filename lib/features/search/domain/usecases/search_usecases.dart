import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';
import 'package:rahmani_project/features/search/domain/repositories/search_repository.dart';

class SearchListings {
  const SearchListings(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<PublicListingSummaryEntity>>> call({
    required SearchFilters filters,
    int limit = SearchResultsPage.pageSize,
    int offset = 0,
  }) {
    final query = filters.query.trim();
    if (query.isNotEmpty && query.length < 2) {
      return Future.value(const Left(ValidationFailure('حداقل ۲ حرف برای جستجو وارد کنید.')));
    }
    return _repository.searchListings(filters: filters, limit: limit, offset: offset);
  }
}

class SearchBooths {
  const SearchBooths(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<FeaturedBoothEntity>>> call({
    required String query,
    int limit = SearchResultsPage.pageSize,
    int offset = 0,
  }) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty && trimmed.length < 2) {
      return Future.value(const Left(ValidationFailure('حداقل ۲ حرف برای جستجو وارد کنید.')));
    }
    return _repository.searchBooths(query: trimmed, limit: limit, offset: offset);
  }
}

class GetMySearchHistory {
  const GetMySearchHistory(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<SearchHistoryEntry>>> call({int limit = 15}) =>
      _repository.getMyHistory(limit: limit);
}

class AddSearchHistory {
  const AddSearchHistory(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, void>> call(String query) => _repository.addHistory(query);
}

class ClearSearchHistory {
  const ClearSearchHistory(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, void>> call() => _repository.clearHistory();
}

class RemoveSearchHistoryEntry {
  const RemoveSearchHistoryEntry(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, void>> call(String entryId) =>
      _repository.removeHistoryEntry(entryId);
}

class GetPopularSearches {
  const GetPopularSearches(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<PopularSearchEntry>>> call({int limit = 10}) =>
      _repository.getPopularSearches(limit: limit);
}

class GetSearchSuggestions {
  const GetSearchSuggestions(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<SearchSuggestion>>> call({
    required String query,
    int limit = 8,
    String kind = 'all',
  }) {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return Future.value(const Right([]));
    }
    return _repository.getSuggestions(query: trimmed, limit: limit, kind: kind);
  }
}
