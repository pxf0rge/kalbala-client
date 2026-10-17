/// Authenticated user profile from domain layer.
class UserEntity {
  const UserEntity({
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
}
