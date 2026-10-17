import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rahmani_project/core/config/app_config.dart';
import 'package:rahmani_project/core/logging/app_logger.dart';

/// Firebase Crashlytics integration (enabled in production only).
abstract final class ErrorReportingService {
  static bool _initialized = false;

  static bool get isEnabled => _initialized && AppConfig.enableCrashReporting;

  static Future<void> initialize() async {
    if (_initialized || !AppConfig.enableCrashReporting || kIsWeb) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(
          FirebaseCrashlytics.instance.recordFlutterFatalError(details),
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
        );
        return true;
      };

      _initialized = true;
      AppLogger.debug('Crashlytics initialized');
    } on Object catch (error) {
      AppLogger.debug('Crashlytics not configured: $error');
    }
  }

  static Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!isEnabled) return;

    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }
}
