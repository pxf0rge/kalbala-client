import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Account settings: notifications, account links, sign-out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: prefsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری تنظیمات…'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(userPreferencesProvider),
        ),
        data: (prefs) {
          final promoEnabled = prefs?.promoNotifications ?? true;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _SettingsGroup(
                title: 'اعلان‌ها',
                children: [
                  SwitchListTile(
                    value: promoEnabled,
                    title: const Text('اعلان‌های پرومو و تخفیف'),
                    subtitle: const Text('کمپین‌های تبلیغاتی و پیشنهادهای ویژه'),
                    onChanged: (value) async {
                      final ok = await ref
                          .read(userPreferencesProvider.notifier)
                          .setPromoNotifications(value);
                      if (!context.mounted) return;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ذخیره تنظیمات ناموفق بود')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('مرکز اعلان‌ها'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsGroup(
                title: 'حساب کاربری',
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('ویرایش پروفایل'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.profileEdit),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android_outlined),
                    title: const Text('تغییر شماره موبایل'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.profileChangePhone),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: const Text('بازیابی حساب'),
                    subtitle: const Text('راهنمای ورود مجدد با همان شماره'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('بازیابی حساب'),
                          content: const Text(
                            'اگر به حساب دسترسی ندارید، با همان شماره موبایل وارد شوید و کد OTP را دریافت کنید. '
                            'برای تغییر شماره از «تغییر شماره موبایل» استفاده کنید.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('متوجه شدم'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.push(RouteNames.profileChangePhone);
                              },
                              child: const Text('تغییر شماره'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('درخواست حذف حساب'),
                    subtitle: const Text('از طریق پشتیبانی پیگیری می‌شود'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.supportCreate),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsGroup(
                title: 'زبان و برنامه',
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('زبان'),
                    subtitle: Text(prefs?.locale == 'en' ? 'English' : 'فارسی'),
                    trailing: const Text('فعلاً فارسی'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('درباره و قوانین'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.about),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('خروج از حساب'),
                      content: const Text('از حساب کاربری خارج می‌شوید؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('انصراف'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('خروج'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true || !context.mounted) return;
                  await ref.read(signOutActionProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('خروج از حساب'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.inkMuted),
          ),
        ),
        Material(
          color: AppColors.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(color: AppColors.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}