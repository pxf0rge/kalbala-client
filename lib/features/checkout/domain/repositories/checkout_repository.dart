import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';

class PlaceOrderInput {
  const PlaceOrderInput({
    required this.addressId,
    required this.paymentMethod,
    this.cartId,
    this.buyerNote,
  });

  final String addressId;
  final CheckoutPaymentMethod paymentMethod;
  final String? cartId;
  final String? buyerNote;
}

abstract interface class CheckoutRepository {
  Future<Either<Failure, PlaceOrderResultEntity>> placeOrder(PlaceOrderInput input);
}
