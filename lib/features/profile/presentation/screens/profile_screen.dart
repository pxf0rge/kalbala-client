import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';
import 'package:rahmani_project/features/notification/presentation/widgets/notification_badge.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Profile hub — KalBala «حساب من» mock layout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _copyPhone(BuildContext context, String phone) async {
    final raw = phone.replaceAll(RegExp(r'\s'), '');
    await Clipboard.setData(ClipboardData(text: raw));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شماره کپی شد')),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true) {
      await ref.read(signOutActionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: profileAsync.when(
          loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری پروفایل…'),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'وارد حساب شوید',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go(RouteNames.login),
                        child: const Text('ورود'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final displayPhone = PhoneUtils.formatForDisplay(profile.phone);
            final hasName = profile.fullName?.trim().isNotEmpty == true;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    avatarUrl: profile.avatarUrl,
                    titleLine:
                        hasName ? profile.fullName!.trim() : 'کاربر کال بالا',
                    subtitleLine: displayPhone,
                    onCopy: () => _copyPhone(context, profile.phone),
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.home);
                      }
                    },
                    onLogout: () => _confirmSignOut(context, ref),
                    onUpload: ({
                      required bytes,
                      required fileExtension,
                      onProgress,
                    }) {
                      return ref.read(profileProvider.notifier).uploadAvatar(
                            bytes: bytes,
                            fileExtension: fileExtension,
                            onProgress: onProgress,
                          );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ProfileGroup(
                        title: 'مدیریت و تنظیمات',
                        children: [
                          _ProfileTile(
                            icon: Icons.person_outline_rounded,
                            iconBg: const Color(0xFFE6F4EF),
                            iconColor: AppColors.primary,
                            title: 'مشخصات شخصی من',
                            subtitle: 'مشاهده و ویرایش اطلاعات',
                            onTap: () => context.push(RouteNames.profileEdit),
                          ),
                          _ProfileTile(
                            icon: Icons.edit_outlined,
                            iconBg: const Color(0xFFE8F1FF),
                            iconColor: const Color(0xFF2563EB),
                            title: 'ویرایش پروفایل',
                            subtitle: 'ویرایش نام، عکس و…',
                            onTap: () => context.push(RouteNames.profileEdit),
                          ),
                          _ProfileTile(
                            icon: Icons.location_on_outlined,
                            iconBg: const Color(0xFFFFF1E8),
                            iconColor: const Color(0xFFEA580C),
                            title: 'آدرس‌های من',
                            subtitle: 'مدیریت آدرس‌های ثبت‌شده',
                            onTap: () => context.push(RouteNames.profileAddresses),
                          ),
                          _ProfileTile(
                            icon: Icons.favorite_border_rounded,
                            iconBg: const Color(0xFFFFF1F2),
                            iconColor: const Color(0xFFE11D48),
                            title: 'علاقه‌مندی‌ها',
                            subtitle: 'محصولات مورد علاقه شما',
                            onTap: () => context.push(RouteNames.favorites),
                          ),
                          _ProfileTile(
                            icon: Icons.storefront_outlined,
                            iconBg: const Color(0xFFF5F3FF),
                            iconColor: const Color(0xFF7C3AED),
                            title: 'فروشگاه‌های دنبال‌شده',
                            subtitle: 'مدیریت فروشگاه‌های دنبال‌شده',
                            onTap: () => context.push(RouteNames.following),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileGroup(
                        title: 'سایر موارد',
                        children: [
                          _ProfileTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            iconBg: const Color(0xFFE6F4EF),
                            iconColor: AppColors.primary,
                            title: 'پیام‌ها',
                            subtitle: 'مشاهده پیام‌ها و اعلان‌ها',
                            onTap: () => context.push(RouteNames.chat),
                          ),
                          _ProfileTile(
                            icon: Icons.notifications_outlined,
                            iconBg: const Color(0xFFFFF7ED),
                            iconColor: const Color(0xFFEA580C),
                            title: 'اعلان‌ها',
                            subtitle: 'تنظیمات اعلان‌ها',
                            trailing: NotificationBadge(count: unreadCount),
                            onTap: () => context.push(RouteNames.notifications),
                          ),
                          _ProfileTile(
                            icon: Icons.settings_outlined,
                            iconBg: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF4F46E5),
                            title: 'تنظیمات',
                            subtitle: 'اعلان پرومو، حساب، خروج',
                            onTap: () => context.push(RouteNames.profileSettings),
                          ),
                          _ProfileTile(
                            icon: Icons.store_outlined,
                            iconBg: const Color(0xFFECFDF5),
                            iconColor: const Color(0xFF059669),
                            title: profile.isSeller ? 'پنل فروشنده' : 'فروشنده شوید',
                            subtitle: profile.isSeller
                                ? 'فروشگاه، محصولات، تسویه'
                                : 'احراز هویت و درخواست فروشگاه',
                            onTap: () => context.push(RouteNames.seller),
                          ),
                          _ProfileTile(
                            icon: Icons.support_agent_outlined,
                            iconBg: const Color(0xFFF0F9FF),
                            iconColor: const Color(0xFF0284C7),
                            title: 'پشتیبانی',
                            subtitle: 'تیکت و راهنما',
                            onTap: () => context.push(RouteNames.support),
                          ),
                          _ProfileTile(
                            icon: Icons.info_outline_rounded,
                            iconBg: const Color(0xFFF8FAFC),
                            iconColor: const Color(0xFF475569),
                            title: 'درباره و قوانین',
                            subtitle: 'قوانین استفاده و حریم خصوصی',
                            onTap: () => context.push(RouteNames.about),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.avatarUrl,
    required this.titleLine,
    required this.subtitleLine,
    required this.onCopy,
    required this.onBack,
    required this.onLogout,
    required this.onUpload,
  });

  final String? avatarUrl;
  final String titleLine;
  final String subtitleLine;
  final VoidCallback onCopy;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final Future<bool> Function({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) onUpload;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 4, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0E5C48),
            AppColors.primary,
            Color(0xFF06382C),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'خروج',
                onPressed: onLogout,
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout_rounded),
              ),
              Expanded(
                child: Text(
                  'حساب من',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'بازگشت',
                onPressed: onBack,
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF127A62),
                  Color(0xFF0A4D3C),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  left: -20,
                  child: _DecorCircle(
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: 40,
                  child: _DecorCircle(
                    size: 130,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Row(
                  children: [
                    AvatarPicker(
                      avatarUrl: avatarUrl,
                      size: 72,
                      onUpload: onUpload,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  subtitleLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: 'کپی شماره',
                                onPressed: onCopy,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  size: 18,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Material(
          color: AppColors.surfaceRaised,
          elevation: 0,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.hairline),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 68,
                      color: AppColors.hairline.withValues(alpha: 0.7),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.inkMuted.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }
}
