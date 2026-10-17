import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';

class VerificationInput {
  const VerificationInput({
    required this.fullName,
    required this.idNumber,
    required this.phone,
    required this.photoBytes,
    required this.photoExtension,
  });

  final String fullName;
  final String idNumber;
  final String phone;
  final List<int> photoBytes;
  final String photoExtension;
}

class BoothApplicationInput {
  const BoothApplicationInput({
    required this.boothName,
    required this.slug,
    required this.ownershipType,
    this.description,
    this.categoryId,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.businessHours,
    this.logoBytes,
    this.logoExtension,
    this.coverBytes,
    this.coverExtension,
    this.logoUrl,
    this.coverUrl,
  });

  final String boothName;
  final String slug;
  final OwnershipType ownershipType;
  final String? description;
  final String? categoryId;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final BusinessHours? businessHours;
  final List<int>? logoBytes;
  final String? logoExtension;
  final List<int>? coverBytes;
  final String? coverExtension;
  final String? logoUrl;
  final String? coverUrl;
}

class BoothUpdateInput {
  const BoothUpdateInput({
    this.name,
    this.description,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.categoryId,
    this.businessHours,
    this.showPhone,
    this.logoBytes,
    this.logoExtension,
    this.coverBytes,
    this.coverExtension,
  });

  final String? name;
  final String? description;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final String? categoryId;
  final BusinessHours? businessHours;
  final bool? showPhone;
  final List<int>? logoBytes;
  final String? logoExtension;
  final List<int>? coverBytes;
  final String? coverExtension;
}

abstract interface class BoothRepository {
  Future<Either<Failure, SellerVerificationEntity?>> getVerificationStatus();

  Future<Either<Failure, SellerVerificationEntity>> submitVerification(
    VerificationInput input, {
    void Function(double progress, String message)? onProgress,
  });

  Future<Either<Failure, BoothApplicationEntity>> applyForBooth(
    BoothApplicationInput input, {
    void Function(double progress, String message)? onProgress,
  });

  Future<Either<Failure, List<BoothApplicationEntity>>> getMyApplications();

  Future<Either<Failure, List<BoothEntity>>> getMyBooths();

  Future<Either<Failure, BoothEntity>> getBooth(String boothId);

  Future<Either<Failure, BoothEntity>> updateBooth({
    required String boothId,
    required BoothUpdateInput input,
    void Function(double progress, String message)? onProgress,
  });

  Future<Either<Failure, BoothEntity>> setBoothActive({
    required String boothId,
    required bool active,
  });
}
