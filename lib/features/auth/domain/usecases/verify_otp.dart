import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/domain/entities/user_entity.dart';
import 'package:rahmani_project/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
  }) {
    final normalizedPhone = PhoneUtils.isValidAfghanPhone(phone)
        ? phone
        : PhoneUtils.normalizeAfghanPhone(phone);

    if (normalizedPhone == null) {
      return Future.value(
        const Left(ValidationFailure('شماره موبایل معتبر نیست.')),
      );
    }

    final code = otp.replaceAll(RegExp(r'\D'), '');
    if (code.length != 6) {
      return Future.value(
        const Left(ValidationFailure('کد تأیید باید ۶ رقم باشد.')),
      );
    }

    return _repository.verifyOtp(phone: normalizedPhone, otp: code);
  }
}
