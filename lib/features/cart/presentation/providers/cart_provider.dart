import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:rahmani_project/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:rahmani_project/features/cart/domain/usecases/cart_usecases.dart';

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return CartRemoteDataSourceImpl(SupabaseConfig.client);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final remote = ref.watch(cartRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredCartRepository();
  return CartRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getCartProvider = Provider((ref) => GetCart(ref.watch(cartRepositoryProvider)));
final addToCartProvider = Provider((ref) => AddToCart(ref.watch(cartRepositoryProvider)));
final updateCartItemQuantityProvider =
    Provider((ref) => UpdateCartItemQuantity(ref.watch(cartRepositoryProvider)));
final removeCartItemProvider =
    Provider((ref) => RemoveCartItem(ref.watch(cartRepositoryProvider)));
final clearCartProvider = Provider((ref) => ClearCart(ref.watch(cartRepositoryProvider)));

final cartProvider = AsyncNotifierProvider<CartNotifier, CartEntity>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider).valueOrNull;
  return cart?.itemCount ?? 0;
});

class CartNotifier extends AsyncNotifier<CartEntity> {
  @override
  Future<CartEntity> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    if (ref.watch(authSessionProvider).valueOrNull == null) {
      return const CartEntity(items: [], boothGroups: []);
    }

    final result = await ref.read(getCartProvider).call();
    return result.fold(
      (_) => const CartEntity(items: [], boothGroups: []),
      (cart) => cart,
    );
  }

  Future<void> refresh() async => ref.invalidateSelf();

  /// Returns `null` on success, otherwise a user-facing error message.
  Future<String?> addToCart(AddToCartInput input) async {
    final result = await ref.read(addToCartProvider).call(input);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<bool> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final result = await ref.read(updateCartItemQuantityProvider).call(
          cartItemId: cartItemId,
          quantity: quantity,
        );
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> removeItem(String cartItemId) async {
    final result = await ref.read(removeCartItemProvider).call(cartItemId);
    return result.fold(
      (_) => false,
      (_) {
        final current = state.valueOrNull;
        if (current != null) {
          final items = current.items.where((item) => item.id != cartItemId).toList();
          state = AsyncData(
            CartEntity(items: items, boothGroups: groupCartItemsByBooth(items)),
          );
        }
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> clearCart() async {
    final result = await ref.read(clearCartProvider).call();
    return result.fold(
      (_) => false,
      (_) {
        state = const AsyncData(CartEntity(items: [], boothGroups: []));
        return true;
      },
    );
  }
}
