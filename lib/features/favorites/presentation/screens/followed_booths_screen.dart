import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/widgets/followed_booth_card.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Booths the user follows.
class FollowedBoothsScreen extends ConsumerStatefulWidget {
  const FollowedBoothsScreen({super.key});

  @override
  ConsumerState<FollowedBoothsScreen> createState() => _FollowedBoothsScreenState();
}

class _FollowedBoothsScreenState extends ConsumerState<FollowedBoothsScreen> {
  final Set<String> _unfollowingIds = {};

  Future<void> _unfollow(FeaturedBoothEntity booth) async {
    if (_unfollowingIds.contains(booth.id)) return;
    setState(() => _unfollowingIds.add(booth.id));
    final success = await ref.read(followedBoothsProvider.notifier).toggle(
          booth.id,
          currentlyFollowing: true,
        );
    if (!mounted) return;
    setState(() => _unfollowingIds.remove(booth.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'دیگر «${booth.name}» را دنبال نمی‌کنید' : 'لغو دنبال ناموفق بود',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boothsAsync = ref.watch(followedBoothsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه‌های دنبال‌شده'),
        actions: [
          boothsAsync.maybeWhen(
            data: (booths) => booths.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          '${booths.length} فروشگاه',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: boothsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری فروشگاه‌ها…'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(followedBoothsProvider),
        ),
        data: (booths) {
          if (booths.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'فروشگاهی دنبال نمی‌کنید',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'با دنبال کردن فروشگاه‌ها، سریع‌تر به فروشگاه‌های مورد علاقه‌تان برگردید.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.go(RouteNames.home),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('جستجو در بازار'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(followedBoothsProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                120,
              ),
              itemCount: booths.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booth = booths[index];
                return Dismissible(
                  key: ValueKey(booth.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _unfollow(booth);
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.person_remove_outlined, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'لغو دنبال',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: FollowedBoothCard(
                    booth: booth,
                    unfollowBusy: _unfollowingIds.contains(booth.id),
                    onOpen: () => context.push(RouteNames.publicBooth(booth.slug)),
                    onUnfollow: () => _unfollow(booth),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
