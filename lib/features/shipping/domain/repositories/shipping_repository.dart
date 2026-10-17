import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';

abstract interface class ShippingRepository {
  Future<Either<Failure, ShippingPreviewEntity>> getCheckoutShippingPreview(
    String addressId,
  );

  Future<Either<Failure, double>> calculateShippingCost({
    required String city,
    required int weightGrams,
  });
}
