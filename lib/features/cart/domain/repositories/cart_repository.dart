import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';

class AddToCartInput {
  const AddToCartInput({
    required this.listingId,
    this.variantId,
    this.quantity = 1,
  });

  final String listingId;
  final String? variantId;
  final int quantity;
}

abstract interface class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, void>> addToCart(AddToCartInput input);

  Future<Either<Failure, void>> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<Either<Failure, void>> removeItem(String cartItemId);

  Future<Either<Failure, void>> clearCart();
}
