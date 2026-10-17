import 'package:rahmani_project/bootstrap.dart';
import 'package:rahmani_project/core/config/app_environment.dart';

/// Single application entry point.
///
/// There are no separate dev/staging/prod entry points anymore. The active
/// environment is selected at build time with `--dart-define=APP_ENV=...`
/// and defaults to `dev`, so a plain `flutter run` just works.
Future<void> main() {
  const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return bootstrap(AppEnvironment.fromString(appEnv));
}
