import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<Either<Failure, void>> removeDeviceToken(String token);

  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, int>> markAllAsRead();

  Stream<void> watchMyNotifications();
}
