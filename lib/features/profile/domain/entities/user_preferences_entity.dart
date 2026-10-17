/// Persisted user preferences (`user_preferences`).
class UserPreferencesEntity {
  const UserPreferencesEntity({
    required this.userId,
    required this.promoNotifications,
    required this.locale,
  });

  final String userId;
  final bool promoNotifications;
  final String locale;

  UserPreferencesEntity copyWith({
    bool? promoNotifications,
    String? locale,
  }) {
    return UserPreferencesEntity(
      userId: userId,
      promoNotifications: promoNotifications ?? this.promoNotifications,
      locale: locale ?? this.locale,
    );
  }
}
