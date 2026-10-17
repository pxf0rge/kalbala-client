import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.phone,
    this.fullName,
    this.avatarUrl,
    this.isSeller = false,
  });

  final String id;
  final String phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isSeller;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isSeller: json['is_seller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toUpdateJson({String? fullName}) {
    return {
      if (fullName != null) 'full_name': fullName,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isSeller: isSeller,
    );
  }
}

class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
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

  final String id;
  final String userId;
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

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      district: json['district'] as String?,
      street: json['street'] as String,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'city': city,
      'district': district,
      'street': street,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'city': city,
      'district': district,
      'street': street,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      userId: userId,
      label: label,
      recipientName: recipientName,
      phone: phone,
      city: city,
      district: district,
      street: street,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}
