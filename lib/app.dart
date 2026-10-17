import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/app_router.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_theme.dart';
import 'package:rahmani_project/core/theme/theme_mode_provider.dart';
import 'package:rahmani_project/features/notification/presentation/widgets/notification_bootstrap.dart';

/// Root application widget.
class RahmaniApp extends ConsumerWidget {
  const RahmaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Keep static AppColors tokens in sync for widgets that read them directly.
    AppColors.applyBrightness(
      themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('fa'),
      supportedLocales: const [
        Locale('fa'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: NotificationBootstrap(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
