import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

class GetFavorites {
  const GetFavorites(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, List<PublicListingSummaryEntity>>> call() =>
      _repository.getFavorites();
}

class IsFavorited {
  const IsFavorited(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, bool>> call(String listingId) =>
      _repository.isFavorited(listingId);
}

class AddFavorite {
  const AddFavorite(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, void>> call(String listingId) =>
      _repository.addFavorite(listingId);
}

class RemoveFavorite {
  const RemoveFavorite(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, void>> call(String listingId) =>
      _repository.removeFavorite(listingId);
}

class GetFollowedBooths {
  const GetFollowedBooths(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, List<FeaturedBoothEntity>>> call() =>
      _repository.getFollowedBooths();
}

class IsFollowing {
  const IsFollowing(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, bool>> call(String boothId) =>
      _repository.isFollowing(boothId);
}

class FollowBooth {
  const FollowBooth(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, void>> call(String boothId) =>
      _repository.followBooth(boothId);
}

class UnfollowBooth {
  const UnfollowBooth(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, void>> call(String boothId) =>
      _repository.unfollowBooth(boothId);
}
