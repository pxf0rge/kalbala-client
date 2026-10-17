import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:rahmani_project/features/notification/data/models/notification_models.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';
import 'package:rahmani_project/features/notification/domain/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final NotificationRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.upsertDeviceToken(token: token, platform: platform);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeDeviceToken(String token) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.deleteDeviceToken(token);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchNotifications(
        limit: limit,
        offset: offset,
        type: type,
      );
      return Right(
        rows.map((row) => NotificationModels.fromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      if (_client.auth.currentUser == null) return const Right(0);
      final count = await _remote.fetchUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.markRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final count = await _remote.markAllRead();
      return Right(count);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<void> watchMyNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();
    return _remote.watchMyNotifications(userId);
  }
}

final class UnconfiguredNotificationRepository implements NotificationRepository {
  const UnconfiguredNotificationRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> removeDeviceToken(String token) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, int>> getUnreadCount() async => const Right(0);

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, int>> markAllAsRead() async => const Left(AuthFailure(_message));

  @override
  Stream<void> watchMyNotifications() => const Stream.empty();
}
