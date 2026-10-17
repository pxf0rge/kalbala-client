import 'package:rahmani_project/core/config/app_environment.dart';

/// Runtime application configuration derived from the active environment.
abstract final class AppConfig {
  static AppEnvironment _environment = AppEnvironment.dev;

  static AppEnvironment get environment => _environment;

  static void configure(AppEnvironment environment) {
    _environment = environment;
  }

  static bool get isProduction => _environment.isProduction;

  static bool get isDevelopment => _environment == AppEnvironment.dev;

  static bool get enableDebugLogging => !isProduction;

  static bool get enableCrashReporting => isProduction;

  static String get environmentLabel => _environment.label;
}
