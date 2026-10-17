import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PreferencesRemoteDataSource {
  Future<Map<String, dynamic>> fetchPreferences();

  Future<Map<String, dynamic>> upsertPreferences({
    bool? promoNotifications,
    String? locale,
  });
}

final class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  PreferencesRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> fetchPreferences() async {
    try {
      final data = await _client.rpc('get_my_preferences');
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> upsertPreferences({
    bool? promoNotifications,
    String? locale,
  }) async {
    try {
      final data = await _client.rpc(
        'upsert_my_preferences',
        params: {
          'p_promo_notifications': promoNotifications,
          'p_locale': locale,
        },
      );
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}

UserPreferencesEntity preferencesFromJson(Map<String, dynamic> json) {
  return UserPreferencesEntity(
    userId: json['user_id'] as String? ?? '',
    promoNotifications: json['promo_notifications'] as bool? ?? true,
    locale: json['locale'] as String? ?? 'fa',
  );
}
