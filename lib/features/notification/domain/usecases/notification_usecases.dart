import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';
import 'package:rahmani_project/features/notification/domain/repositories/notification_repository.dart';

class RegisterDeviceToken {
  const RegisterDeviceToken(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, void>> call({
    required String token,
    required String platform,
  }) {
    if (token.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('توکن دستگاه نامعتبر است.')));
    }
    return _repository.registerDeviceToken(token: token.trim(), platform: platform);
  }
}

class GetNotifications {
  const GetNotifications(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, List<NotificationEntity>>> call({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
    String? type,
  }) =>
      _repository.getNotifications(limit: limit, offset: offset, type: type);
}

class GetUnreadNotificationCount {
  const GetUnreadNotificationCount(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, int>> call() => _repository.getUnreadCount();
}

class MarkNotificationRead {
  const MarkNotificationRead(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, void>> call(String notificationId) {
    if (notificationId.isEmpty) {
      return Future.value(const Left(ValidationFailure('اعلان نامعتبر است.')));
    }
    return _repository.markAsRead(notificationId);
  }
}

class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, int>> call() => _repository.markAllAsRead();
}

class RemoveDeviceToken {
  const RemoveDeviceToken(this._repository);
  final NotificationRepository _repository;

  Future<Either<Failure, void>> call(String token) {
    if (token.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('توکن دستگاه نامعتبر است.')));
    }
    return _repository.removeDeviceToken(token.trim());
  }
}
