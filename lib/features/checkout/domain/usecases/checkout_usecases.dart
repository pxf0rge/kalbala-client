import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';

class GetCheckoutSummary {
  CheckoutSummaryEntity call({
    required List<CartItemEntity> items,
    ShippingPreviewEntity? shippingPreview,
  }) =>
      buildCheckoutSummary(items: items, shippingPreview: shippingPreview);
}

class PlaceOrder {
  const PlaceOrder(this._repository);
  final CheckoutRepository _repository;

  Future<Either<Failure, PlaceOrderResultEntity>> call(PlaceOrderInput input) {
    if (input.addressId.isEmpty) {
      return Future.value(const Left(ValidationFailure('آدرس تحویل انتخاب نشده است.')));
    }
    return _repository.placeOrder(input);
  }
}
