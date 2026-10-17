import 'package:flutter/material.dart';

/// Notification event types (matches DB enum).
enum NotificationType {
  order,
  payment,
  orderStatus,
  message,
  booth,
  promotion,
  system;

  String get dbValue => switch (this) {
        NotificationType.order => 'order',
        NotificationType.payment => 'payment',
        NotificationType.orderStatus => 'order_status',
        NotificationType.message => 'message',
        NotificationType.booth => 'booth',
        NotificationType.promotion => 'promotion',
        NotificationType.system => 'system',
      };

  static NotificationType fromDb(String value) => switch (value) {
        'order' => NotificationType.order,
        'payment' => NotificationType.payment,
        'order_status' => NotificationType.orderStatus,
        'message' => NotificationType.message,
        'booth' => NotificationType.booth,
        'promotion' => NotificationType.promotion,
        _ => NotificationType.system,
      };

  String get labelFa => switch (this) {
        NotificationType.order => 'سفارش',
        NotificationType.payment => 'پرداخت',
        NotificationType.orderStatus => 'وضعیت سفارش',
        NotificationType.message => 'پیام',
        NotificationType.booth => 'فروشگاه',
        NotificationType.promotion => 'پرومو',
        NotificationType.system => 'سیستم',
      };

  IconData get icon => switch (this) {
        NotificationType.order => Icons.receipt_long_outlined,
        NotificationType.payment => Icons.payments_outlined,
        NotificationType.orderStatus => Icons.local_shipping_outlined,
        NotificationType.message => Icons.chat_bubble_outline,
        NotificationType.booth => Icons.storefront_outlined,
        NotificationType.promotion => Icons.campaign_outlined,
        NotificationType.system => Icons.notifications_outlined,
      };
}

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.isRead,
    required this.createdAt,
    this.body,
    this.data = const {},
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  String? get deepLink => data['deep_link'] as String?;
}

/// Maps push/in-app payload to a navigation path.
String? resolveNotificationDeepLink(Map<String, dynamic> data) {
  final deepLink = data['deep_link'];
  if (deepLink is String && deepLink.isNotEmpty) return deepLink;

  final listingId = data['listing_id'];
  if (listingId is String && listingId.isNotEmpty) return '/product/$listingId';

  final boothSlug = data['booth_slug'];
  if (boothSlug is String && boothSlug.isNotEmpty) return '/booth/$boothSlug';

  final boothId = data['booth_id'];
  if (boothId is String && boothId.isNotEmpty) return '/booth/$boothId';

  final orderId = data['order_id'];
  if (orderId is String && orderId.isNotEmpty) return '/orders/$orderId';

  final sellerOrderId = data['seller_order_id'];
  if (sellerOrderId is String && sellerOrderId.isNotEmpty) {
    return '/seller/orders/$sellerOrderId';
  }

  final conversationId = data['conversation_id'];
  if (conversationId is String && conversationId.isNotEmpty) {
    return '/chat/$conversationId';
  }

  return null;
}
