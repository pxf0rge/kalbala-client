import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rahmani_project/features/auth/domain/entities/user_entity.dart';
import 'package:rahmani_project/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> sendOtp(String phone) async {
    try {
      await _remote.sendOtp(phone);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final user = await _remote.verifyOtp(phone: phone, otp: otp);
      return Right(user.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String?>> requestPhoneChange(String newPhone) async {
    try {
      final otp = await _remote.requestPhoneChange(newPhone);
      return Right(otp);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> confirmPhoneChange({
    required String newPhone,
    required String otp,
  }) async {
    try {
      final user = await _remote.confirmPhoneChange(
        newPhone: newPhone,
        otp: otp,
      );
      return Right(user.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ({bool blocked, String message})>> getAccountRecoveryHint(
    String phone,
  ) async {
    try {
      final hint = await _remote.getAccountRecoveryHint(phone);
      return Right(hint);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final session = _remote.currentSession;
      if (session == null) return const Right(null);

      final user = session.user;
      final profile = await _remote.fetchProfile(user.id);
      if (profile != null) return Right(profile.toEntity());

      final phone = (user.phone ?? user.userMetadata?['phone']?.toString() ?? '')
          .trim();
      if (phone.isEmpty) return const Right(null);

      final ensured = await _remote.ensureProfile(user.id, phone: phone);
      return Right(ensured.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

/// Fallback when Supabase is not configured (dev without .env).
final class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _message = 'Supabase پیکربندی نشده است. فایل .env را تنظیم کنید.';

  @override
  Future<Either<Failure, void>> sendOtp(String phone) async {
    return const Left(AuthFailure(_message));
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return const Left(AuthFailure(_message));
  }

  @override
  Future<Either<Failure, String?>> requestPhoneChange(String newPhone) async {
    return const Left(AuthFailure(_message));
  }

  @override
  Future<Either<Failure, UserEntity>> confirmPhoneChange({
    required String newPhone,
    required String otp,
  }) async {
    return const Left(AuthFailure(_message));
  }

  @override
  Future<Either<Failure, ({bool blocked, String message})>> getAccountRecoveryHint(
    String phone,
  ) async {
    return const Left(AuthFailure(_message));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    return const Right(null);
  }
}
