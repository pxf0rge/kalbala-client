import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';

class SellerVerificationEntity {
  const SellerVerificationEntity({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.fullName,
    required this.idNumber,
    required this.phone,
    required this.status,
    this.rejectionReason,
  });

  final String id;
  final String userId;
  final String photoUrl;
  final String fullName;
  final String idNumber;
  final String phone;
  final ApprovalStatus status;
  final String? rejectionReason;

  bool get isApproved => status == ApprovalStatus.approved;
  bool get isPending => status == ApprovalStatus.pending;
  bool get isRejected => status == ApprovalStatus.rejected;
}

class BoothApplicationEntity {
  const BoothApplicationEntity({
    required this.id,
    required this.userId,
    required this.boothName,
    required this.slug,
    required this.ownershipType,
    required this.status,
    this.description,
    this.categoryId,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.logoUrl,
    this.coverUrl,
    this.businessHours = const BusinessHours(),
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String boothName;
  final String slug;
  final OwnershipType ownershipType;
  final ApprovalStatus status;
  final String? description;
  final String? categoryId;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final String? logoUrl;
  final String? coverUrl;
  final BusinessHours businessHours;
  final String? rejectionReason;
  final DateTime? createdAt;

  bool get isPending => status == ApprovalStatus.pending;
  bool get isRejected => status == ApprovalStatus.rejected;
}

class BoothEntity {
  const BoothEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    required this.ownershipType,
    required this.approvalStatus,
    required this.isActive,
    this.applicationId,
    this.logoUrl,
    this.coverUrl,
    this.description,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.categoryId,
    this.businessHours = const BusinessHours(),
    this.rentalStart,
    this.rentalEnd,
    this.isBlocked = false,
    this.showPhone = true,
    this.viewCount = 0,
    this.followerCount = 0,
  });

  final String id;
  final String ownerId;
  final String? applicationId;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final String? categoryId;
  final BusinessHours businessHours;
  final OwnershipType ownershipType;
  final ApprovalStatus approvalStatus;
  final bool isActive;
  final DateTime? rentalStart;
  final DateTime? rentalEnd;
  final bool isBlocked;
  final bool showPhone;
  final int viewCount;
  final int followerCount;

  bool get isRental => ownershipType == OwnershipType.rental;
  bool get isRentalExpired =>
      isRental && rentalEnd != null && rentalEnd!.isBefore(DateTime.now());
  bool get isPubliclyVisible =>
      isActive && approvalStatus == ApprovalStatus.approved && !isBlocked && !isRentalExpired;
}
