import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/booth_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// List of booths owned by the current seller.
class MyBoothsScreen extends ConsumerWidget {
  const MyBoothsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boothsAsync = ref.watch(myBoothsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه‌های من'),
        actions: [
          IconButton(
            tooltip: 'به‌روزرسانی',
            onPressed: () => ref.read(myBoothsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: boothsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری فروشگاه‌ها...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (booths) {
          if (booths.isEmpty) {
            return const AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'هنوز فروشگاهی ندارید',
              subtitle: 'پس از تأیید درخواست، فروشگاه شما اینجا نمایش داده می‌شود.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(myBoothsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  'فروشگاه‌های فعال شما',
                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${booths.length} فروشگاه برای مدیریت و ویرایش',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...List.generate(booths.length, (index) {
                  final booth = booths[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == booths.length - 1 ? 0 : AppSpacing.md,
                    ),
                    child: BoothCard(
                      booth: booth,
                      onTap: () => context.push(RouteNames.sellerBoothDetail(booth.id)),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}