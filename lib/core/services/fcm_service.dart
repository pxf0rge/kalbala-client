import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rahmani_project/core/logging/app_logger.dart';

typedef NotificationTapHandler = void Function(Map<String, dynamic> data);

/// Optional Firebase Cloud Messaging integration.
///
/// Gracefully no-ops when Firebase is not configured (missing platform files).
class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  bool _initialized = false;
  String? _currentToken;
  NotificationTapHandler? _onNotificationTap;

  bool get isAvailable => _initialized;
  String? get currentToken => _currentToken;

  Future<void> initialize({NotificationTapHandler? onNotificationTap}) async {
    if (_initialized || kIsWeb) return;

    _onNotificationTap = onNotificationTap;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleOpenedMessage(initialMessage);
      }

      _currentToken = await messaging.getToken();
      messaging.onTokenRefresh.listen((token) => _currentToken = token);

      _initialized = true;
    } on Object catch (error) {
      AppLogger.debug('FCM not configured: $error');
    }
  }

  String get platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.debug('Foreground push: ${message.notification?.title}');
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    _onNotificationTap?.call(data);
  }

  Future<void> dispose() async {
    _currentToken = null;
    _initialized = false;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}
