import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Seller hub — entry point for verification, application, and booth management.
class SellerHubScreen extends ConsumerWidget {
  const SellerHubScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(verificationProvider.notifier).refresh(),
      ref.read(myApplicationsProvider.notifier).refresh(),
      ref.read(myBoothsProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationAsync = ref.watch(verificationProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final boothsAsync = ref.watch(myBoothsProvider);
    final theme = Theme.of(context);
    final latestApplication = applicationsAsync.valueOrNull?.isNotEmpty == true
        ? applicationsAsync.valueOrNull!.first
        : null;
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل فروشنده'),
        actions: [
          IconButton(
            tooltip: 'اعلان‌ها',
            onPressed: () => context.push(RouteNames.notifications),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(fontSize: 10),
              ),
              child: Icon(
                unreadCount > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
              ),
            ),
          ),
          IconButton(
            tooltip: 'به‌روزرسانی وضعیت',
            onPressed: () => _refreshAll(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: verificationAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => _refreshAll(ref),
        ),
        data: (verification) {
          return RefreshIndicator(
            onRefresh: () => _refreshAll(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  'مدیریت فروش',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'احراز هویت، فروشگاه، سفارش و تسویه',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _HubGroup(
                  children: [
                    _HubTile(
                      icon: Icons.verified_user_outlined,
                      title: 'احراز هویت فروشنده',
                      subtitle: verification == null
                          ? const Text('هنوز ارسال نشده')
                          : VerificationStatusBadge(
                              status: verification.status,
                            ),
                      onTap: () => context.push(RouteNames.sellerVerify),
                    ),
                    _HubTile(
                      icon: Icons.add_business_outlined,
                      title: 'درخواست فروشگاه جدید',
                      subtitle: latestApplication == null
                          ? const Text('خرید دائمی یا اجاره‌ای')
                          : VerificationStatusBadge(
                              status: latestApplication.status,
                            ),
                      onTap: () => context.push(RouteNames.sellerApply),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _HubGroup(
                  children: [
                    _HubTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'محصولات من',
                      subtitle: const Text('کاتالوگ سراسری محصولات'),
                      onTap: () => context.push(RouteNames.sellerProducts),
                    ),
                    _HubTile(
                      icon: Icons.category_outlined,
                      title: 'دسته‌بندی‌ها',
                      onTap: () => context.push(RouteNames.sellerCategories),
                    ),
                    _HubTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'سفارش‌های فروش',
                      subtitle: const Text('مدیریت و ارسال سفارش‌ها'),
                      onTap: () => context.push(RouteNames.sellerOrders),
                    ),
                    _HubTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'مالی و تسویه',
                      subtitle: const Text('موجودی، حساب بانکی و درخواست تسویه'),
                      onTap: () => context.push(RouteNames.sellerBalance),
                    ),
                    _HubTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'گفتگوهای فروش',
                      subtitle: const Text('پاسخ به پیام‌های خریداران'),
                      onTap: () => context.push(RouteNames.chat),
                    ),
                    _HubTile(
                      icon: Icons.storefront_outlined,
                      title: 'فروشگاه‌های من',
                      subtitle: boothsAsync.when(
                        data: (booths) => Text('${booths.length} فروشگاه'),
                        loading: () => const Text('...'),
                        error: (_, _) => const Text('خطا'),
                      ),
                      onTap: () => context.push(RouteNames.sellerBooths),
                    ),
                  ],
                ),
                if (verification?.isRejected == true &&
                    verification!.rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Material(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'دلیل رد احراز هویت: ${verification.rejectionReason}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
                if (latestApplication?.isRejected == true &&
                    latestApplication!.rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Material(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'دلیل رد درخواست فروشگاه: ${latestApplication.rejectionReason}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HubGroup extends StatelessWidget {
  const _HubGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.hairline),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final Widget? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle,
      trailing: Icon(Icons.chevron_left, color: AppColors.inkMuted),
    );
  }
}
