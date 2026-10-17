import 'package:rahmani_project/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client initialization and access.
abstract final class SupabaseConfig {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (!Env.isConfigured) {
      throw StateError(
        'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY '
        'via .env or --dart-define for ${Env.environment.label}.',
      );
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase has not been initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }
}
