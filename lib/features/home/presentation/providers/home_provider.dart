import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/home/data/datasources/analytics_remote_datasource.dart';
import 'package:rahmani_project/features/home/data/datasources/home_remote_datasource.dart';
import 'package:rahmani_project/features/home/data/repositories/home_repository_impl.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/domain/repositories/home_repository.dart';
import 'package:rahmani_project/features/home/domain/usecases/home_usecases.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return HomeRemoteDataSourceImpl(SupabaseConfig.client);
});

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return AnalyticsRemoteDataSourceImpl(SupabaseConfig.client);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remote = ref.watch(homeRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredHomeRepository();
  return HomeRepositoryImpl(remote);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final remote = ref.watch(analyticsRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredAnalyticsRepository();
  return AnalyticsRepositoryImpl(remote);
});

final getHomeFeedProvider = Provider((ref) => GetHomeFeed(ref.watch(homeRepositoryProvider)));
final getFeaturedBoothsProvider =
    Provider((ref) => GetFeaturedBooths(ref.watch(homeRepositoryProvider)));
final getFeaturedProductsProvider =
    Provider((ref) => GetFeaturedProducts(ref.watch(homeRepositoryProvider)));
final getCategoryListingsProvider =
    Provider((ref) => GetCategoryListings(ref.watch(homeRepositoryProvider)));
final getChildCategoriesProvider =
    Provider((ref) => GetChildCategories(ref.watch(homeRepositoryProvider)));
final getPublicBoothProvider =
    Provider((ref) => GetPublicBooth(ref.watch(homeRepositoryProvider)));
final incrementBoothViewProvider =
    Provider((ref) => IncrementBoothView(ref.watch(homeRepositoryProvider)));
final trackEventProvider =
    Provider((ref) => TrackEvent(ref.watch(analyticsRepositoryProvider)));

final homeFeedProvider = AsyncNotifierProvider<HomeFeedNotifier, HomeFeedEntity?>(
  HomeFeedNotifier.new,
);

class HomeFeedNotifier extends AsyncNotifier<HomeFeedEntity?> {
  @override
  Future<HomeFeedEntity?> build() async {
    final result = await ref.read(getHomeFeedProvider).call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (feed) => feed,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final childCategoriesProvider =
    FutureProvider.family<List<CategorySummaryEntity>, String?>((ref, parentId) async {
  final result = await ref.read(getChildCategoriesProvider).call(parentId: parentId);
  return result.fold((failure) => throw Exception(failure.message), (cats) => cats);
});

final categoryListingsProvider = AsyncNotifierProvider.family<
    CategoryListingsNotifier, CategoryListingsPage, String>(
  CategoryListingsNotifier.new,
);

class CategoryListingsNotifier
    extends FamilyAsyncNotifier<CategoryListingsPage, String> {
  CategoryBrowseFilters _filters = const CategoryBrowseFilters();
  bool _loadingMore = false;

  @override
  Future<CategoryListingsPage> build(String categoryId) async {
    _filters = const CategoryBrowseFilters();
    return _fetch(offset: 0);
  }

  Future<CategoryListingsPage> _fetch({required int offset}) async {
    final scopeId = _filters.selectedChildId ?? arg;
    final result = await ref.read(getCategoryListingsProvider).call(
          scopeId,
          limit: CategoryListingsPage.pageSize,
          offset: offset,
          sort: _filters.sort,
          minPrice: _filters.minPrice,
          maxPrice: _filters.maxPrice,
          query: _filters.query.trim().isEmpty ? null : _filters.query.trim(),
        );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (page) => CategoryListingsPage(
        listings: page.listings,
        hasMore: page.hasMore,
        offset: page.offset,
        filters: _filters,
      ),
    );
  }

  Future<void> applyFilters(CategoryBrowseFilters filters) async {
    _filters = filters;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(offset: 0));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(offset: 0));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await _fetch(offset: current.offset);
      state = AsyncData(
        CategoryListingsPage(
          listings: [...current.listings, ...next.listings],
          hasMore: next.hasMore,
          offset: next.offset,
          filters: _filters,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _loadingMore = false;
    }
  }
}

final publicBoothProvider =
    AsyncNotifierProvider.family<PublicBoothNotifier, FeaturedBoothEntity?, String>(
  PublicBoothNotifier.new,
);

class PublicBoothNotifier extends FamilyAsyncNotifier<FeaturedBoothEntity?, String> {
  @override
  Future<FeaturedBoothEntity?> build(String slug) async {
    final result = await ref.read(getPublicBoothProvider).call(slug);
    return result.fold((_) => null, (booth) => booth);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Optimistic +1 after a successful public view track.
  void bumpViewCount() {
    final booth = state.valueOrNull;
    if (booth == null) return;
    state = AsyncData(booth.copyWith(viewCount: booth.viewCount + 1));
  }

  /// Optimistic follower delta after follow/unfollow (clamped at 0).
  void adjustFollowerCount(int delta) {
    final booth = state.valueOrNull;
    if (booth == null || delta == 0) return;
    final next = booth.followerCount + delta;
    state = AsyncData(booth.copyWith(followerCount: next < 0 ? 0 : next));
  }
}

final boothSummaryProvider =
    FutureProvider.family<BoothSummaryEntity?, String>((ref, slug) async {
  final result = await ref.read(homeRepositoryProvider).getBoothSummary(slug);
  return result.fold((_) => null, (summary) => summary);
});
