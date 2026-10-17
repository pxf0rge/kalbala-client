import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/core/utils/slug_utils.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';

class GetVerificationStatus {
  const GetVerificationStatus(this._repository);
  final BoothRepository _repository;
  Future<Either<Failure, SellerVerificationEntity?>> call() =>
      _repository.getVerificationStatus();
}

class SubmitVerification {
  const SubmitVerification(this._repository);
  final BoothRepository _repository;

  Future<Either<Failure, SellerVerificationEntity>> call(
    VerificationInput input, {
    void Function(double progress, String message)? onProgress,
  }) {
    if (input.fullName.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('نام کامل الزامی است.')));
    }
    if (input.idNumber.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('شماره تذکره الزامی است.')));
    }
    final phone = PhoneUtils.normalizeAfghanPhone(input.phone) ??
        (PhoneUtils.isValidAfghanPhone(input.phone) ? input.phone : null);
    if (phone == null) {
      return Future.value(const Left(ValidationFailure('شماره موبایل معتبر نیست.')));
    }
    return _repository.submitVerification(
      VerificationInput(
        fullName: input.fullName.trim(),
        idNumber: input.idNumber.trim(),
        phone: phone,
        photoBytes: input.photoBytes,
        photoExtension: input.photoExtension,
      ),
      onProgress: onProgress,
    );
  }
}

class ApplyForBooth {
  const ApplyForBooth(this._repository);
  final BoothRepository _repository;

  Future<Either<Failure, BoothApplicationEntity>> call(
    BoothApplicationInput input, {
    void Function(double progress, String message)? onProgress,
  }) {
    final slug = SlugUtils.slugify(input.slug);
    if (!SlugUtils.isValid(slug)) {
      return Future.value(
        const Left(ValidationFailure('نامک فروشگاه فقط حروف انگلیسی کوچک، عدد و خط تیره باشد.')),
      );
    }
    if (input.boothName.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('نام فروشگاه الزامی است.')));
    }

    String? phone;
    if (input.phone != null && input.phone!.trim().isNotEmpty) {
      phone = PhoneUtils.normalizeAfghanPhone(input.phone!) ??
          (PhoneUtils.isValidAfghanPhone(input.phone!) ? input.phone : null);
      if (phone == null) {
        return Future.value(const Left(ValidationFailure('شماره تماس فروشگاه معتبر نیست.')));
      }
    }

    return _repository.applyForBooth(
      BoothApplicationInput(
        boothName: input.boothName.trim(),
        slug: slug,
        ownershipType: input.ownershipType,
        description: input.description?.trim(),
        categoryId: input.categoryId,
        phone: phone,
        address: input.address?.trim(),
        city: input.city,
        province: input.province,
        businessHours: input.businessHours ?? BusinessHours.defaults(),
        logoBytes: input.logoBytes,
        logoExtension: input.logoExtension,
        coverBytes: input.coverBytes,
        coverExtension: input.coverExtension,
      ),
      onProgress: onProgress,
    );
  }
}

class GetMyApplications {
  const GetMyApplications(this._repository);
  final BoothRepository _repository;
  Future<Either<Failure, List<BoothApplicationEntity>>> call() =>
      _repository.getMyApplications();
}

class GetMyBooths {
  const GetMyBooths(this._repository);
  final BoothRepository _repository;
  Future<Either<Failure, List<BoothEntity>>> call() => _repository.getMyBooths();
}

class GetBooth {
  const GetBooth(this._repository);
  final BoothRepository _repository;
  Future<Either<Failure, BoothEntity>> call(String boothId) =>
      _repository.getBooth(boothId);
}

class UpdateBooth {
  const UpdateBooth(this._repository);
  final BoothRepository _repository;

  Future<Either<Failure, BoothEntity>> call({
    required String boothId,
    required BoothUpdateInput input,
    void Function(double progress, String message)? onProgress,
  }) {
    var phone = input.phone;
    if (phone != null) {
      phone = PhoneUtils.normalizeAfghanPhone(phone) ??
          (PhoneUtils.isValidAfghanPhone(phone) ? phone : null);
      if (phone == null) {
        return Future.value(const Left(ValidationFailure('شماره تماس فروشگاه معتبر نیست.')));
      }
    }
    return _repository.updateBooth(
      boothId: boothId,
      input: BoothUpdateInput(
        name: input.name,
        description: input.description,
        phone: phone,
        address: input.address,
        city: input.city,
        province: input.province,
        categoryId: input.categoryId,
        businessHours: input.businessHours,
        showPhone: input.showPhone,
        logoBytes: input.logoBytes,
        logoExtension: input.logoExtension,
        coverBytes: input.coverBytes,
        coverExtension: input.coverExtension,
      ),
      onProgress: onProgress,
    );
  }
}

class SetBoothActive {
  const SetBoothActive(this._repository);
  final BoothRepository _repository;

  Future<Either<Failure, BoothEntity>> call({
    required String boothId,
    required bool active,
  }) =>
      _repository.setBoothActive(boothId: boothId, active: active);
}
