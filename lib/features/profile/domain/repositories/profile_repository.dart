import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';

/// Input for creating or updating an address.
class AddressInput {
  const AddressInput({
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.street,
    this.district,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String label;
  final String recipientName;
  final String phone;
  final String city;
  final String? district;
  final String street;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
}

abstract interface class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();

  Future<Either<Failure, ProfileEntity>> updateProfile({String? fullName});

  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  });
}

abstract interface class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  Future<Either<Failure, AddressEntity>> addAddress(AddressInput input);

  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    required AddressInput input,
  });

  Future<Either<Failure, void>> deleteAddress(String addressId);

  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId);
}
