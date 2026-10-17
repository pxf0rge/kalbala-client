/// User profile from the `profiles` table.
class ProfileEntity {
  const ProfileEntity({
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

  String get displayName => fullName?.trim().isNotEmpty == true ? fullName! : phone;
}
