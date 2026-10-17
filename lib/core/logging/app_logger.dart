import 'package:flutter/foundation.dart';
import 'package:rahmani_project/core/config/app_config.dart';
import 'package:rahmani_project/core/services/error_reporting_service.dart';

/// Application logger that suppresses debug output in production builds.
abstract final class AppLogger {
  static void debug(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint(message);
    }
  }

  static void warning(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('WARNING: $message');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('ERROR: $message${error != null ? ' ($error)' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }

    if (error != null) {
      ErrorReportingService.recordError(
        error,
        stackTrace ?? StackTrace.current,
        reason: message,
        fatal: fatal,
      );
    }
  }
}
