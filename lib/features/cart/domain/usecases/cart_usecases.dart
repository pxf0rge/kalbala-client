import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/cart/domain/repositories/cart_repository.dart';

class GetCart {
  const GetCart(this._repository);
  final CartRepository _repository;

  Future<Either<Failure, CartEntity>> call() => _repository.getCart();
}

class AddToCart {
  const AddToCart(this._repository);
  final CartRepository _repository;

  Future<Either<Failure, void>> call(AddToCartInput input) {
    if (input.quantity <= 0) {
      return Future.value(const Left(ValidationFailure('تعداد نامعتبر است.')));
    }
    if (input.listingId.isEmpty) {
      return Future.value(const Left(ValidationFailure('لیستینگ نامعتبر است.')));
    }
    return _repository.addToCart(input);
  }
}

class UpdateCartItemQuantity {
  const UpdateCartItemQuantity(this._repository);
  final CartRepository _repository;

  Future<Either<Failure, void>> call({
    required String cartItemId,
    required int quantity,
  }) {
    if (quantity < 0) {
      return Future.value(const Left(ValidationFailure('تعداد نامعتبر است.')));
    }
    return _repository.updateQuantity(cartItemId: cartItemId, quantity: quantity);
  }
}

class RemoveCartItem {
  const RemoveCartItem(this._repository);
  final CartRepository _repository;

  Future<Either<Failure, void>> call(String cartItemId) =>
      _repository.removeItem(cartItemId);
}

class ClearCart {
  const ClearCart(this._repository);
  final CartRepository _repository;

  Future<Either<Failure, void>> call() => _repository.clearCart();
}

class GetCartGroupedByBooth {
  List<CartBoothGroupEntity> call(List<CartItemEntity> items) =>
      groupCartItemsByBooth(items);
}
