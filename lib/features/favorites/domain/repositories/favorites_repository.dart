import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

abstract interface class FavoritesRepository {
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFavorites();

  Future<Either<Failure, bool>> isFavorited(String listingId);

  Future<Either<Failure, void>> addFavorite(String listingId);

  Future<Either<Failure, void>> removeFavorite(String listingId);

  Future<Either<Failure, List<FeaturedBoothEntity>>> getFollowedBooths();

  Future<Either<Failure, bool>> isFollowing(String boothId);

  Future<Either<Failure, void>> followBooth(String boothId);

  Future<Either<Failure, void>> unfollowBooth(String boothId);
}
