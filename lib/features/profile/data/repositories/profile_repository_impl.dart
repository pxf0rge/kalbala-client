import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rahmani_project/features/profile/data/models/profile_models.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource profileRemote,
    required SupabaseClient client,
  })  : _profileRemote = profileRemote,
        _client = client;

  final ProfileRemoteDataSource _profileRemote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final profile = await _profileRemote.fetchProfile(userId);
      return Right(profile.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? fullName}) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final profile = await _profileRemote.updateProfile(
        userId: userId,
        fullName: fullName,
      );
      return Right(profile.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      report(0.1, 'در حال آپلود تصویر…');
      final avatarUrl = await _profileRemote.uploadAvatar(
        userId: userId,
        bytes: bytes,
        fileExtension: fileExtension,
      );
      report(0.75, 'در حال به‌روزرسانی پروفایل…');
      final profile = await _profileRemote.updateProfile(
        userId: userId,
        avatarUrl: avatarUrl,
      );
      report(1, 'آپلود کامل شد');
      return Right(profile.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({
    required AddressRemoteDataSource addressRemote,
    required SupabaseClient client,
  })  : _addressRemote = addressRemote,
        _client = client;

  final AddressRemoteDataSource _addressRemote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final addresses = await _addressRemote.fetchAddresses(userId);
      return Right(addresses.map((a) => a.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> addAddress(AddressInput input) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      final model = AddressModel(
        id: '',
        userId: userId,
        label: input.label,
        recipientName: input.recipientName,
        phone: input.phone,
        city: input.city,
        district: input.district,
        street: input.street,
        postalCode: input.postalCode,
        latitude: input.latitude,
        longitude: input.longitude,
        isDefault: input.isDefault,
      );
      final created = await _addressRemote.insertAddress(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    required AddressInput input,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      final model = AddressModel(
        id: addressId,
        userId: userId,
        label: input.label,
        recipientName: input.recipientName,
        phone: input.phone,
        city: input.city,
        district: input.district,
        street: input.street,
        postalCode: input.postalCode,
        latitude: input.latitude,
        longitude: input.longitude,
        isDefault: input.isDefault,
      );
      final updated = await _addressRemote.updateAddress(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      await _addressRemote.deleteAddress(addressId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final updated = await _addressRemote.setDefaultAddress(
        userId: userId,
        addressId: addressId,
      );
      return Right(updated.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredProfileRepository implements ProfileRepository {
  const UnconfiguredProfileRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? fullName}) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));
}

final class UnconfiguredAddressRepository implements AddressRepository {
  const UnconfiguredAddressRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, AddressEntity>> addAddress(AddressInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    required AddressInput input,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId) async =>
      const Left(AuthFailure(_message));
}
