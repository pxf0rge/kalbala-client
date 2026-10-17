import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';

class GetAddresses {
  const GetAddresses(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, List<AddressEntity>>> call() => _repository.getAddresses();
}

class AddAddress {
  const AddAddress(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, AddressEntity>> call(AddressInput input) {
    final normalizedPhone = PhoneUtils.normalizeAfghanPhone(input.phone) ??
        (PhoneUtils.isValidAfghanPhone(input.phone) ? input.phone : null);

    if (normalizedPhone == null) {
      return Future.value(
        const Left(ValidationFailure('شماره تماس آدرس معتبر نیست.')),
      );
    }

    return _repository.addAddress(
      AddressInput(
        label: input.label.trim(),
        recipientName: input.recipientName.trim(),
        phone: normalizedPhone,
        city: input.city.trim(),
        district: input.district?.trim(),
        street: input.street.trim(),
        postalCode: input.postalCode?.trim(),
        latitude: input.latitude,
        longitude: input.longitude,
        isDefault: input.isDefault,
      ),
    );
  }
}

class UpdateAddress {
  const UpdateAddress(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, AddressEntity>> call({
    required String addressId,
    required AddressInput input,
  }) {
    final normalizedPhone = PhoneUtils.normalizeAfghanPhone(input.phone) ??
        (PhoneUtils.isValidAfghanPhone(input.phone) ? input.phone : null);

    if (normalizedPhone == null) {
      return Future.value(
        const Left(ValidationFailure('شماره تماس آدرس معتبر نیست.')),
      );
    }

    return _repository.updateAddress(
      addressId: addressId,
      input: AddressInput(
        label: input.label.trim(),
        recipientName: input.recipientName.trim(),
        phone: normalizedPhone,
        city: input.city.trim(),
        district: input.district?.trim(),
        street: input.street.trim(),
        postalCode: input.postalCode?.trim(),
        latitude: input.latitude,
        longitude: input.longitude,
        isDefault: input.isDefault,
      ),
    );
  }
}

class DeleteAddress {
  const DeleteAddress(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, void>> call(String addressId) =>
      _repository.deleteAddress(addressId);
}

class SetDefaultAddress {
  const SetDefaultAddress(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, AddressEntity>> call(String addressId) =>
      _repository.setDefaultAddress(addressId);
}
