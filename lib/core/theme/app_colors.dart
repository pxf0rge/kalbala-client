import 'package:flutter/material.dart';

/// KalBala (کال بالا) palette — emerald commerce brand.
abstract final class AppColors {
  static Brightness _brightness = Brightness.light;

  static bool get isDark => _brightness == Brightness.dark;

  /// Call when theme mode changes so static tokens track light/dark.
  static void applyBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  // Brand
  static const Color primary = Color(0xFF0A4D3C);
  static const Color primaryMid = Color(0xFF0D6B56);
  static const Color accent = Color(0xFFE2A116);

  static Color get primarySoft =>
      isDark ? const Color(0xFF14352D) : const Color(0xFFE6F4EF);

  static Color get secondary =>
      isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1A2E28);
  static Color get secondarySoft =>
      isDark ? const Color(0xFF1A2E28) : const Color(0xFFEEF3F1);

  // Surfaces
  static Color get canvas =>
      isDark ? const Color(0xFF0C1210) : const Color(0xFFF3F6F5);
  static Color get surface =>
      isDark ? const Color(0xFF141C19) : const Color(0xFFFFFFFF);
  static Color get surfaceRaised =>
      isDark ? const Color(0xFF1A2420) : const Color(0xFFFFFFFF);
  static Color get ink =>
      isDark ? const Color(0xFFF3F4F6) : const Color(0xFF14201C);
  static Color get inkMuted =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF5F736C);
  static Color get hairline =>
      isDark ? const Color(0xFF2A3833) : const Color(0xFFDCE6E2);

  // Semantic
  static const Color error = Color(0xFFD92D20);
  static Color get errorSoft =>
      isDark ? const Color(0xFF3F1512) : const Color(0xFFFEE4E2);
  static const Color success = Color(0xFF079455);
  static const Color warning = Color(0xFFDC6803);

  // Legacy aliases
  static const Color primaryDark = primaryMid;
  static Color get onSurfaceVariant => inkMuted;

  /// Splash / hero brand gradient.
  static const List<Color> brandGradient = [
    Color(0xFF127A62),
    primary,
    Color(0xFF06382C),
  ];
}
