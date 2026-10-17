import 'package:rahmani_project/features/auth/domain/entities/user_entity.dart';

/// Maps `profiles` table row to [UserEntity].
class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    this.fullName,
    this.avatarUrl,
    this.isBlocked = false,
    this.isSeller = false,
  });

  final String id;
  final String phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isBlocked;
  final bool isSeller;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      isSeller: json['is_seller'] as bool? ?? false,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isBlocked: isBlocked,
      isSeller: isSeller,
    );
  }
}
