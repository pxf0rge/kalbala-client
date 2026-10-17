import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';

/// Vazirmatn-based type scale (Persian-first).
abstract final class AppTextStyles {
  static TextTheme textTheme({Color? ink, Color? inkMuted}) {
    final inkColor = ink ?? AppColors.ink;
    final mutedColor = inkMuted ?? AppColors.inkMuted;
    final base = GoogleFonts.vazirmatnTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
        color: inkColor,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: inkColor,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: inkColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: inkColor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: inkColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: inkColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: inkColor,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: inkColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: inkColor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: inkColor,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: mutedColor,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: inkColor,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: mutedColor,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: mutedColor,
      ),
    );
  }

  static TextStyle get brandMark => GoogleFonts.vazirmatn(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.1,
        color: AppColors.primary,
      );

  /// Marketplace price — bold ink (Torob pattern); red reserved for CTAs/discounts.
  static TextStyle get price => GoogleFonts.vazirmatn(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.2,
      );
}
