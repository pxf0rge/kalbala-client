import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Whether Supabase was initialized at app startup.
final supabaseReadyProvider = Provider<bool>((ref) {
  return SupabaseConfig.isInitialized;
});

/// Supabase client for repositories and data sources.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});
