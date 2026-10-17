import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:rahmani_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:rahmani_project/features/home/data/models/home_models.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required FavoritesRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final FavoritesRemoteDataSource _remote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFavorites() async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final data = await _remote.fetchFavorites();
      final models = data
          .map((row) => PublicListingSummaryModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorited(String listingId) async {
    try {
      if (_userId == null) return const Right(false);
      final favorited = await _remote.checkFavorited(listingId);
      return Right(favorited);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String listingId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.insertFavorite(listingId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String listingId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.deleteFavorite(listingId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getFollowedBooths() async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final data = await _remote.fetchFollowedBooths();
      final models = data
          .map((row) => FeaturedBoothModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowing(String boothId) async {
    try {
      if (_userId == null) return const Right(false);
      final following = await _remote.checkFollowing(boothId);
      return Right(following);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> followBooth(String boothId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.insertFollow(boothId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowBooth(String boothId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.deleteFollow(boothId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredFavoritesRepository implements FavoritesRepository {
  const UnconfiguredFavoritesRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<PublicListingSummaryEntity>>> getFavorites() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, bool>> isFavorited(String listingId) async => const Right(false);

  @override
  Future<Either<Failure, void>> addFavorite(String listingId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> removeFavorite(String listingId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<FeaturedBoothEntity>>> getFollowedBooths() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, bool>> isFollowing(String boothId) async => const Right(false);

  @override
  Future<Either<Failure, void>> followBooth(String boothId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> unfollowBooth(String boothId) async =>
      const Left(AuthFailure(_message));
}
