import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/app.dart';
import 'package:rahmani_project/core/config/app_config.dart';
import 'package:rahmani_project/core/config/app_environment.dart';
import 'package:rahmani_project/core/config/env.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/core/logging/app_logger.dart';
import 'package:rahmani_project/core/services/error_reporting_service.dart';
import 'package:rahmani_project/core/services/fcm_service.dart';

/// Shared application bootstrap for all entry points.
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.configure(environment);
  AppLogger.debug('Starting Rahmani (${AppConfig.environmentLabel})');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await runZonedGuarded(() async {
    await Env.load(environment: environment);
    await ErrorReportingService.initialize();

    if (Env.isConfigured) {
      await SupabaseConfig.initialize();
    } else {
      AppLogger.warning('Supabase credentials not configured');
    }

    runApp(const ProviderScope(child: RahmaniApp()));
  }, (error, stackTrace) {
    AppLogger.error(
      'Unhandled zone error',
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
  });
}
