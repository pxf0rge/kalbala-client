import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/domain/repositories/auth_repository.dart';

class SendOtp {
  const SendOtp(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call(String phoneInput) {
    final phone = PhoneUtils.normalizeAfghanPhone(phoneInput);
    if (phone == null) {
      return Future.value(
        const Left(ValidationFailure('شماره موبایل معتبر نیست. مثال: 0700123456')),
      );
    }
    return _repository.sendOtp(phone);
  }
}
