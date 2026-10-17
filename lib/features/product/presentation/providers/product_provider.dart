import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/product/data/datasources/product_remote_datasource.dart';
import 'package:rahmani_project/features/product/data/repositories/product_repository_impl.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/entities/product_entity.dart';
import 'package:rahmani_project/features/product/domain/repositories/product_repository.dart';
import 'package:rahmani_project/features/product/domain/usecases/product_usecases.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ProductRemoteDataSourceImpl(SupabaseConfig.client);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remote = ref.watch(productRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredProductRepository();
  return ProductRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getCategoriesProvider = Provider((ref) => GetCategories(ref.watch(productRepositoryProvider)));
final getMyProductsProvider = Provider((ref) => GetMyProducts(ref.watch(productRepositoryProvider)));
final createProductProvider = Provider((ref) => CreateProduct(ref.watch(productRepositoryProvider)));
final updateProductProvider = Provider((ref) => UpdateProduct(ref.watch(productRepositoryProvider)));
final deleteProductProvider = Provider((ref) => DeleteProduct(ref.watch(productRepositoryProvider)));

final productDetailProvider = FutureProvider.family<ProductEntity?, String>((ref, productId) async {
  final result = await ref.watch(productRepositoryProvider).getProduct(productId);
  return result.fold((_) => null, (product) => product);
});

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    final result = await ref.read(getCategoriesProvider).call();
    return result.fold((_) => [], (categories) => categories);
  }
}

final myProductsProvider = AsyncNotifierProvider<MyProductsNotifier, List<ProductEntity>>(
  MyProductsNotifier.new,
);

class MyProductsNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return [];

    final result = await ref.read(getMyProductsProvider).call();
    return result.fold((_) => [], (products) => products);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> remove(String productId) async {
    final result = await ref.read(deleteProductProvider).call(productId);
    return result.fold(
      (_) => false,
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(current.where((p) => p.id != productId).toList());
        return true;
      },
    );
  }
}
