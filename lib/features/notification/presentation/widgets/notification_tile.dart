import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';

/// Single notification list item.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd('fa').add_Hm();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: notification.isRead ? null : colorScheme.primaryContainer.withValues(alpha: 0.25),
      child: ListTile(
        leading: Icon(notification.type.icon),
        title: Text(
          notification.title,
          style: notification.isRead
              ? null
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.body != null && notification.body!.isNotEmpty)
              Text(
                notification.body!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Icon(Icons.circle, size: 10, color: colorScheme.primary),
        onTap: onTap,
      ),
    );
  }
}
