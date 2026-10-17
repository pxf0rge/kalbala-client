import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';

class SellerVerificationModel {
  const SellerVerificationModel({
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
  final String status;
  final String? rejectionReason;

  factory SellerVerificationModel.fromJson(Map<String, dynamic> json) {
    return SellerVerificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      photoUrl: json['photo_url'] as String,
      fullName: json['full_name'] as String,
      idNumber: json['id_number'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  SellerVerificationEntity toEntity() {
    return SellerVerificationEntity(
      id: id,
      userId: userId,
      photoUrl: photoUrl,
      fullName: fullName,
      idNumber: idNumber,
      phone: phone,
      status: ApprovalStatus.fromDb(status),
      rejectionReason: rejectionReason,
    );
  }
}

class BoothApplicationModel {
  const BoothApplicationModel({
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
    this.businessHours,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String boothName;
  final String slug;
  final String ownershipType;
  final String status;
  final String? description;
  final String? categoryId;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final String? logoUrl;
  final String? coverUrl;
  final Map<String, dynamic>? businessHours;
  final String? rejectionReason;
  final DateTime? createdAt;

  factory BoothApplicationModel.fromJson(Map<String, dynamic> json) {
    return BoothApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      boothName: json['booth_name'] as String,
      slug: json['slug'] as String,
      ownershipType: json['ownership_type'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      businessHours: json['business_hours'] is Map
          ? Map<String, dynamic>.from(json['business_hours'] as Map)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  BoothApplicationEntity toEntity() {
    return BoothApplicationEntity(
      id: id,
      userId: userId,
      boothName: boothName,
      slug: slug,
      ownershipType: OwnershipType.fromDb(ownershipType),
      status: ApprovalStatus.fromDb(status),
      description: description,
      categoryId: categoryId,
      phone: phone,
      address: address,
      city: city,
      province: province,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      businessHours: BusinessHours.fromJson(businessHours),
      rejectionReason: rejectionReason,
      createdAt: createdAt,
    );
  }
}

class BoothModel {
  const BoothModel({
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
    this.businessHours,
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
  final Map<String, dynamic>? businessHours;
  final String ownershipType;
  final String approvalStatus;
  final bool isActive;
  final String? rentalStart;
  final String? rentalEnd;
  final bool isBlocked;
  final bool showPhone;
  final int viewCount;
  final int followerCount;

  factory BoothModel.fromJson(Map<String, dynamic> json) {
    return BoothModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      applicationId: json['application_id'] as String?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      categoryId: json['category_id'] as String?,
      businessHours: json['business_hours'] is Map
          ? Map<String, dynamic>.from(json['business_hours'] as Map)
          : null,
      ownershipType: json['ownership_type'] as String,
      approvalStatus: json['approval_status'] as String,
      isActive: json['is_active'] as bool? ?? false,
      rentalStart: json['rental_start'] as String?,
      rentalEnd: json['rental_end'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      showPhone: json['show_phone'] as bool? ?? true,
      viewCount: json['view_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
    );
  }

  BoothEntity toEntity() {
    return BoothEntity(
      id: id,
      ownerId: ownerId,
      applicationId: applicationId,
      name: name,
      slug: slug,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      description: description,
      phone: phone,
      address: address,
      city: city,
      province: province,
      categoryId: categoryId,
      businessHours: BusinessHours.fromJson(businessHours),
      ownershipType: OwnershipType.fromDb(ownershipType),
      approvalStatus: ApprovalStatus.fromDb(approvalStatus),
      isActive: isActive,
      rentalStart: rentalStart != null ? DateTime.parse(rentalStart!) : null,
      rentalEnd: rentalEnd != null ? DateTime.parse(rentalEnd!) : null,
      isBlocked: isBlocked,
      showPhone: showPhone,
      viewCount: viewCount,
      followerCount: followerCount,
    );
  }
}
