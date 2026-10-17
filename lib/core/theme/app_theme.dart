import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/theme/app_text_styles.dart';

/// Application theme — Material 3 KalBala chrome (light + dark).
abstract final class AppTheme {
  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData get light => _light ??= _build(Brightness.light);

  static ThemeData get dark => _dark ??= _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const primary = AppColors.primary;
    const primaryMid = AppColors.primaryMid;
    final primarySoft =
        isDark ? const Color(0xFF14352D) : const Color(0xFFE6F4EF);
    final secondary =
        isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1A2E28);
    final secondarySoft =
        isDark ? const Color(0xFF1A2E28) : const Color(0xFFEEF3F1);
    final canvas = isDark ? const Color(0xFF0C1210) : const Color(0xFFF3F6F5);
    final surface = isDark ? const Color(0xFF141C19) : const Color(0xFFFFFFFF);
    final surfaceRaised =
        isDark ? const Color(0xFF1A2420) : const Color(0xFFFFFFFF);
    final ink = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF14201C);
    final inkMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF5F736C);
    final hairline = isDark ? const Color(0xFF2A3833) : const Color(0xFFDCE6E2);
    final errorSoft =
        isDark ? const Color(0xFF3F1512) : const Color(0xFFFEE4E2);

    final textTheme = AppTextStyles.textTheme(ink: ink, inkMuted: inkMuted);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primarySoft,
      onPrimaryContainer: isDark ? const Color(0xFF9FE0CB) : primaryMid,
      secondary: secondary,
      onSecondary: isDark ? const Color(0xFF111827) : Colors.white,
      secondaryContainer: secondarySoft,
      onSecondaryContainer: secondary,
      tertiary: AppColors.accent,
      onTertiary: const Color(0xFF1A1400),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: errorSoft,
      onErrorContainer: AppColors.error,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkMuted,
      outline: hairline,
      outlineVariant: hairline,
      shadow: const Color(0x1A000000),
      scrim: const Color(0x99000000),
      inverseSurface: ink,
      onInverseSurface: surface,
      inversePrimary: primarySoft,
      surfaceTint: primary,
    );

    final shapeMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      dividerColor: hairline,
      dividerTheme: DividerThemeData(
        color: hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: surfaceRaised,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 56,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: inkMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0x400A4D3C),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          foregroundColor: ink,
          side: BorderSide(color: hairline, width: 1.2),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceRaised,
        selectedColor: primarySoft,
        side: BorderSide(color: hairline),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: shapeMd,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: inkMuted,
        textColor: ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? const Color(0xFF111827) : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: shapeMd,
        titleTextStyle: textTheme.headlineSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.navHeight,
        backgroundColor: surfaceRaised,
        indicatorColor: primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? primary : inkMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : inkMuted,
            size: 24,
          );
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: primarySoft,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.accent,
        textColor: Color(0xFF1A1400),
      ),
      iconTheme: IconThemeData(color: ink),
    );
  }
}
