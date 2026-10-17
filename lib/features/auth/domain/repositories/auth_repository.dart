import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/auth/domain/entities/user_entity.dart';

/// Contract for phone OTP authentication and session management.
abstract interface class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phone);

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, String?>> requestPhoneChange(String newPhone);

  Future<Either<Failure, UserEntity>> confirmPhoneChange({
    required String newPhone,
    required String otp,
  });

  Future<Either<Failure, ({bool blocked, String message})>> getAccountRecoveryHint(
    String phone,
  );

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
