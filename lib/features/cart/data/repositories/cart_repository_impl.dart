import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:rahmani_project/features/cart/data/models/cart_models.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required CartRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final CartRemoteDataSource _remote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      final data = await _remote.fetchCartDetails();
      final items = data
          .map((row) => CartItemModel.fromJson(row as Map<String, dynamic>).toEntity())
          .toList();
      return Right(
        CartEntity(
          items: items,
          boothGroups: groupCartItemsByBooth(items),
        ),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(AddToCartInput input) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.addToCart(
        listingId: input.listingId,
        variantId: input.variantId,
        quantity: input.quantity,
      );
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.updateQuantity(cartItemId: cartItemId, quantity: quantity);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(String cartItemId) async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.removeItem(cartItemId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      if (_userId == null) return const Left(AuthFailure());
      await _remote.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredCartRepository implements CartRepository {
  const UnconfiguredCartRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, CartEntity>> getCart() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> addToCart(AddToCartInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> removeItem(String cartItemId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> clearCart() async =>
      const Left(AuthFailure(_message));
}
