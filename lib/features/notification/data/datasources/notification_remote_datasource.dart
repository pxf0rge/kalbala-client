import 'dart:async';

import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class NotificationRemoteDataSource {
  Future<void> upsertDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> deleteDeviceToken(String token);

  Future<List<dynamic>> fetchNotifications({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  });

  Future<int> fetchUnreadCount();

  Future<void> markRead(String notificationId);

  Future<int> markAllRead();

  /// Emits whenever the current user's notifications change (insert/update).
  Stream<void> watchMyNotifications(String userId);
}

final class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsertDeviceToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _client.rpc(
        'register_device_token',
        params: {
          'p_token': token,
          'p_platform': platform,
        },
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> deleteDeviceToken(String token) async {
    try {
      await _client.rpc('remove_device_token', params: {'p_token': token});
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchNotifications({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  }) async {
    try {
      final data = await _client.rpc(
        'get_my_notifications',
        params: {
          'p_limit': limit,
          'p_offset': offset,
          'p_type': type,
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<int> fetchUnreadCount() async {
    try {
      final data = await _client.rpc('get_unread_notification_count');
      return data as int? ?? 0;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await _client.rpc(
        'mark_notification_read',
        params: {'p_notification_id': notificationId},
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<int> markAllRead() async {
    try {
      final data = await _client.rpc('mark_all_notifications_read');
      return data as int? ?? 0;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Stream<void> watchMyNotifications(String userId) {
    final controller = StreamController<void>.broadcast();
    final channel = _client.channel('notifications:$userId');

    void emit() {
      if (!controller.isClosed) controller.add(null);
    }

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => emit(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
}
