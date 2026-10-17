import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';
import 'package:rahmani_project/features/shipping/domain/repositories/shipping_repository.dart';

class GetCheckoutShippingPreview {
  const GetCheckoutShippingPreview(this._repository);
  final ShippingRepository _repository;

  Future<Either<Failure, ShippingPreviewEntity>> call(String addressId) {
    if (addressId.isEmpty) {
      return Future.value(const Left(ValidationFailure('آدرس انتخاب نشده است.')));
    }
    return _repository.getCheckoutShippingPreview(addressId);
  }
}

class CalculateShippingCost {
  const CalculateShippingCost(this._repository);
  final ShippingRepository _repository;

  Future<Either<Failure, double>> call({
    required String city,
    required int weightGrams,
  }) =>
      _repository.calculateShippingCost(city: city, weightGrams: weightGrams);
}
