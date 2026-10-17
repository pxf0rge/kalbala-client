import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';
import 'package:rahmani_project/features/seller_dashboard/presentation/providers/seller_dashboard_provider.dart';
import 'package:rahmani_project/features/seller_dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:rahmani_project/features/seller_dashboard/presentation/widgets/kpi_card.dart';
import 'package:rahmani_project/features/seller_dashboard/presentation/widgets/top_products_list.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Seller dashboard with KPIs, top products, and quick navigation.
class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sellerDashboardProvider);
    final verificationAsync = ref.watch(verificationProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final boothsAsync = ref.watch(myBoothsProvider);
    final priceFormat = NumberFormat('#,##0', 'fa');
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
            onPressed: () async {
              ref.invalidate(sellerDashboardProvider);
              await Future.wait([
                ref.read(verificationProvider.notifier).refresh(),
                ref.read(myApplicationsProvider.notifier).refresh(),
                ref.read(myBoothsProvider.notifier).refresh(),
              ]);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sellerDashboardProvider);
          await Future.wait([
            ref.read(verificationProvider.notifier).refresh(),
            ref.read(myApplicationsProvider.notifier).refresh(),
            ref.read(myBoothsProvider.notifier).refresh(),
          ]);
        },
        child: statsAsync.when(
          loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری داشبورد...'),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(sellerDashboardProvider),
          ),
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  'نمای کلی فروش',
                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'آمار عملکرد، محصولات پرفروش و میانبرهای مدیریت',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.xl),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.28,
                  children: [
                    KpiCard(
                      label: 'سفارش‌ها',
                      value: priceFormat.format(stats.orderCount),
                      icon: Icons.receipt_long_outlined,
                    ),
                    KpiCard(
                      label: 'فروش کل',
                      value:
                          '${priceFormat.format(stats.totalSales)} ${AppConstants.currencySymbol}',
                      icon: Icons.payments_outlined,
                    ),
                    KpiCard(
                      label: 'موجودی قابل برداشت',
                      value:
                          '${priceFormat.format(stats.availableBalance)} ${AppConstants.currencySymbol}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    KpiCard(
                      label: 'محصولات',
                      value: priceFormat.format(stats.productCount),
                      icon: Icons.inventory_2_outlined,
                    ),
                    KpiCard(
                      label: 'بازدید فروشگاه',
                      value: priceFormat.format(stats.boothViews),
                      icon: Icons.visibility_outlined,
                    ),
                    KpiCard(
                      label: 'دنبال‌کنندگان',
                      value: priceFormat.format(stats.followerCount),
                      icon: Icons.people_outline,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                DashboardChart(products: stats.topProducts),
                const SizedBox(height: AppSpacing.lg),
                TopProductsList(products: stats.topProducts),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: AppSpacing.sm),
                  child: Text(
                    'دسترسی سریع',
                    style: theme.textTheme.labelLarge?.copyWith(color: AppColors.inkMuted),
                  ),
                ),
                Material(
                  color: AppColors.surfaceRaised,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(color: AppColors.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _QuickLinkTile(
                        icon: Icons.verified_user_outlined,
                        title: 'احراز هویت فروشنده',
                        subtitle: verificationAsync.when(
                          data: (verification) => verification == null
                              ? const Text('هنوز ارسال نشده')
                              : VerificationStatusBadge(status: verification.status),
                          loading: () => const Text('...'),
                          error: (_, _) => const Text('خطا'),
                        ),
                        onTap: () => context.push(RouteNames.sellerVerify),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.add_business_outlined,
                        title: 'درخواست فروشگاه جدید',
                        subtitle: latestApplication == null
                            ? const Text('خرید دائمی یا اجاره‌ای')
                            : VerificationStatusBadge(
                                status: latestApplication.status,
                              ),
                        onTap: () => context.push(RouteNames.sellerApply),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'سفارش‌های فروش',
                        onTap: () => context.push(RouteNames.sellerOrders),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'مالی و تسویه',
                        onTap: () => context.push(RouteNames.sellerBalance),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.inventory_2_outlined,
                        title: 'محصولات من',
                        onTap: () => context.push(RouteNames.sellerProducts),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.storefront_outlined,
                        title: 'فروشگاه‌های من',
                        subtitle: boothsAsync.when(
                          data: (booths) => Text('${booths.length} فروشگاه'),
                          loading: () => const Text('...'),
                          error: (_, _) => const Text('خطا'),
                        ),
                        onTap: () => context.push(RouteNames.sellerBooths),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      _QuickLinkTile(
                        icon: Icons.chat_bubble_outline,
                        title: 'گفتگوهای فروش',
                        onTap: () => context.push(RouteNames.chat),
                      ),
                    ],
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

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
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