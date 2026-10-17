import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';

class NotificationModels {
  static NotificationEntity fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromDb(json['type'] as String? ?? 'system'),
      title: json['title'] as String,
      body: json['body'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
