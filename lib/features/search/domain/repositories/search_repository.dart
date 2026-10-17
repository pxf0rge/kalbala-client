import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';

abstract interface class SearchRepository {
  Future<Either<Failure, List<PublicListingSummaryEntity>>> searchListings({
    required SearchFilters filters,
    required int limit,
    required int offset,
  });

  Future<Either<Failure, List<FeaturedBoothEntity>>> searchBooths({
    required String query,
    required int limit,
    required int offset,
  });

  Future<Either<Failure, List<SearchHistoryEntry>>> getMyHistory({int limit = 15});

  Future<Either<Failure, void>> addHistory(String query);

  Future<Either<Failure, void>> clearHistory();

  Future<Either<Failure, void>> removeHistoryEntry(String entryId);

  Future<Either<Failure, List<PopularSearchEntry>>> getPopularSearches({int limit = 10});

  Future<Either<Failure, List<SearchSuggestion>>> getSuggestions({
    required String query,
    int limit = 8,
    String kind = 'all',
  });
}
