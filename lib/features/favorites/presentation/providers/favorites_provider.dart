import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:rahmani_project/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:rahmani_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:rahmani_project/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';

final favoritesRemoteDataSourceProvider = Provider<FavoritesRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return FavoritesRemoteDataSourceImpl(SupabaseConfig.client);
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final remote = ref.watch(favoritesRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredFavoritesRepository();
  return FavoritesRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getFavoritesProvider = Provider((ref) => GetFavorites(ref.watch(favoritesRepositoryProvider)));
final addFavoriteProvider = Provider((ref) => AddFavorite(ref.watch(favoritesRepositoryProvider)));
final removeFavoriteProvider =
    Provider((ref) => RemoveFavorite(ref.watch(favoritesRepositoryProvider)));
final getFollowedBoothsProvider =
    Provider((ref) => GetFollowedBooths(ref.watch(favoritesRepositoryProvider)));
final followBoothProvider = Provider((ref) => FollowBooth(ref.watch(favoritesRepositoryProvider)));
final unfollowBoothProvider =
    Provider((ref) => UnfollowBooth(ref.watch(favoritesRepositoryProvider)));

final isFavoritedProvider = FutureProvider.family<bool, String>((ref, listingId) async {
  if (ref.watch(authSessionProvider).valueOrNull == null) return false;
  final result = await ref.watch(favoritesRepositoryProvider).isFavorited(listingId);
  return result.fold((_) => false, (value) => value);
});

final isFollowingProvider = FutureProvider.family<bool, String>((ref, boothId) async {
  if (ref.watch(authSessionProvider).valueOrNull == null) return false;
  final result = await ref.watch(favoritesRepositoryProvider).isFollowing(boothId);
  return result.fold((_) => false, (value) => value);
});

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<PublicListingSummaryEntity>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<PublicListingSummaryEntity>> {
  @override
  Future<List<PublicListingSummaryEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    if (ref.watch(authSessionProvider).valueOrNull == null) return [];

    final result = await ref.read(getFavoritesProvider).call();
    return result.fold((_) => [], (items) => items);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> toggle(String listingId, {required bool currentlyFavorited}) async {
    final result = currentlyFavorited
        ? await ref.read(removeFavoriteProvider).call(listingId)
        : await ref.read(addFavoriteProvider).call(listingId);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidate(isFavoritedProvider(listingId));
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> remove(String listingId) async {
    final result = await ref.read(removeFavoriteProvider).call(listingId);
    return result.fold(
      (_) => false,
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(current.where((item) => item.id != listingId).toList());
        ref.invalidate(isFavoritedProvider(listingId));
        return true;
      },
    );
  }
}

final followedBoothsProvider =
    AsyncNotifierProvider<FollowedBoothsNotifier, List<FeaturedBoothEntity>>(
  FollowedBoothsNotifier.new,
);

class FollowedBoothsNotifier extends AsyncNotifier<List<FeaturedBoothEntity>> {
  @override
  Future<List<FeaturedBoothEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    if (ref.watch(authSessionProvider).valueOrNull == null) return [];

    final result = await ref.read(getFollowedBoothsProvider).call();
    return result.fold((_) => [], (booths) => booths);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> toggle(String boothId, {required bool currentlyFollowing}) async {
    final result = currentlyFollowing
        ? await ref.read(unfollowBoothProvider).call(boothId)
        : await ref.read(followBoothProvider).call(boothId);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidate(isFollowingProvider(boothId));
        ref.invalidateSelf();
        return true;
      },
    );
  }
}
