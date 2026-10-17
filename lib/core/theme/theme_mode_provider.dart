import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'rahmani_theme_mode';

/// Persisted light / dark theme preference.
final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.light) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == 'dark') {
      state = ThemeMode.dark;
      AppColors.applyBrightness(Brightness.dark);
    } else {
      state = ThemeMode.light;
      AppColors.applyBrightness(Brightness.light);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode == ThemeMode.system ? ThemeMode.light : mode;
    AppColors.applyBrightness(
      state == ThemeMode.dark ? Brightness.dark : Brightness.light,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeModeKey,
      state == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> toggle() async {
    await setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
