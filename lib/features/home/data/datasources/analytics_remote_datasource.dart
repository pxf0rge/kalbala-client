import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AnalyticsRemoteDataSource {
  Future<void> trackEvent({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  });
}

final class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<void> trackEvent({
    required AnalyticsEventType eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await _client.rpc(
        'track_analytics_event',
        params: {
          'p_event_type': eventType.dbValue,
          'p_entity_type': entityType,
          'p_entity_id': entityId,
          'p_metadata': metadata,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
