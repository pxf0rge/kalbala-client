import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:rahmani_project/features/listing/data/repositories/listing_repository_impl.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/repositories/listing_repository.dart';
import 'package:rahmani_project/features/listing/domain/usecases/listing_usecases.dart';

final listingRemoteDataSourceProvider = Provider<ListingRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ListingRemoteDataSourceImpl(SupabaseConfig.client);
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final remote = ref.watch(listingRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredListingRepository();
  return ListingRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getBoothListingsProvider =
    Provider((ref) => GetBoothListings(ref.watch(listingRepositoryProvider)));
final createListingProvider =
    Provider((ref) => CreateListing(ref.watch(listingRepositoryProvider)));
final updateListingProvider =
    Provider((ref) => UpdateListing(ref.watch(listingRepositoryProvider)));
final deleteListingProvider =
    Provider((ref) => DeleteListing(ref.watch(listingRepositoryProvider)));
final addVariantProvider =
    Provider((ref) => AddVariant(ref.watch(listingRepositoryProvider)));
final updateVariantProvider =
    Provider((ref) => UpdateVariant(ref.watch(listingRepositoryProvider)));
final deleteVariantProvider =
    Provider((ref) => DeleteVariant(ref.watch(listingRepositoryProvider)));

final listingDetailProvider = FutureProvider.family<ListingEntity?, String>((ref, listingId) async {
  final result = await ref.watch(listingRepositoryProvider).getListing(listingId);
  return result.fold((_) => null, (listing) => listing);
});

final publicListingDetailProvider =
    FutureProvider.family<PublicListingEntity?, String>((ref, listingId) async {
  final result = await ref.watch(listingRepositoryProvider).getPublicListing(listingId);
  return result.fold((_) => null, (listing) => listing);
});

final publicBoothListingsProvider =
    FutureProvider.family<List<PublicListingEntity>, String>((ref, boothSlug) async {
  final result = await ref.watch(listingRepositoryProvider).getPublicBoothListings(boothSlug);
  return result.fold((_) => [], (listings) => listings);
});

typedef BoothCatalogQuery = ({
  String boothId,
  String? categoryId,
  String sort,
});

final boothCatalogListingsProvider =
    FutureProvider.family<List<PublicListingEntity>, BoothCatalogQuery>((ref, query) async {
  final result = await ref.watch(listingRepositoryProvider).getBoothCatalogListings(
        boothId: query.boothId,
        categoryId: query.categoryId,
        sort: query.sort,
      );
  return result.fold((_) => [], (listings) => listings);
});

final boothBestsellersProvider =
    FutureProvider.family<List<PublicListingEntity>, String>((ref, boothId) async {
  final result = await ref.watch(listingRepositoryProvider).getBoothBestsellers(boothId);
  return result.fold((_) => [], (listings) => listings);
});

final boothNewListingsProvider =
    FutureProvider.family<List<PublicListingEntity>, String>((ref, boothId) async {
  final result = await ref.watch(listingRepositoryProvider).getBoothNewListings(boothId);
  return result.fold((_) => [], (listings) => listings);
});

final getRelatedListingsProvider =
    Provider((ref) => GetRelatedListings(ref.watch(listingRepositoryProvider)));

final relatedListingsProvider =
    FutureProvider.family<List<PublicListingEntity>, String>((ref, listingId) async {
  final result = await ref.watch(getRelatedListingsProvider).call(listingId);
  return result.fold((_) => [], (listings) => listings);
});

final boothListingsProvider =
    AsyncNotifierProvider.family<BoothListingsNotifier, List<ListingEntity>, String>(
  BoothListingsNotifier.new,
);

class BoothListingsNotifier extends FamilyAsyncNotifier<List<ListingEntity>, String> {
  @override
  Future<List<ListingEntity>> build(String boothId) async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final result = await ref.read(getBoothListingsProvider).call(boothId);
    return result.fold((_) => [], (listings) => listings);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> remove(String listingId) async {
    final result = await ref.read(deleteListingProvider).call(listingId);
    return result.fold(
      (_) => false,
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(current.where((l) => l.id != listingId).toList());
        return true;
      },
    );
  }
}
