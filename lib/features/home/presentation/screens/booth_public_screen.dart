import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/chat/presentation/providers/chat_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/widgets/follow_button.dart';
import 'package:rahmani_project/features/home/domain/entities/home_entities.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/home/presentation/widgets/booth_header.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/listing_card.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_action.dart';
import 'package:rahmani_project/features/review/presentation/widgets/review_list.dart';
import 'package:rahmani_project/features/review/presentation/widgets/star_rating.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public booth profile with header, listings, and view tracking.
class BoothPublicScreen extends ConsumerStatefulWidget {
  const BoothPublicScreen({required this.boothSlug, super.key});

  final String boothSlug;

  @override
  ConsumerState<BoothPublicScreen> createState() => _BoothPublicScreenState();
}

class _BoothPublicScreenState extends ConsumerState<BoothPublicScreen> {
  bool _viewTracked = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackView());
  }

  Future<void> _trackView() async {
    if (_viewTracked) return;
    final booth = await ref.read(publicBoothProvider(widget.boothSlug).future);
    if (booth == null || !mounted) return;
    _viewTracked = true;
    final result = await ref.read(incrementBoothViewProvider).call(booth.id);
    if (!mounted) return;
    result.fold((_) {}, (_) {
      ref.read(publicBoothProvider(widget.boothSlug).notifier).bumpViewCount();
    });
  }

  Future<void> _share(FeaturedBoothEntity booth) async {
    final text = [
      'فروشگاه ${booth.name}',
      if (booth.city != null) 'شهر: ${booth.city}',
      if (booth.description != null && booth.description!.isNotEmpty)
        booth.description!,
    ].join('\n');
    await Share.share(text);
  }

  Future<void> _startChat(BuildContext context, String boothId, String boothName) async {
    final result = await ref.read(startConversationProvider).call(boothId);
    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (conversationId) {
        ref.invalidate(conversationsProvider);
        context.push(RouteNames.chatDetail(conversationId), extra: boothName);
      },
    );
  }

  Future<void> _callPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان برقراری تماس وجود ندارد')),
      );
    }
  }

  Future<void> _refresh(String boothId) async {
    ref.invalidate(publicBoothProvider(widget.boothSlug));
    ref.invalidate(boothSummaryProvider(widget.boothSlug));
    ref.invalidate(boothBestsellersProvider(boothId));
    ref.invalidate(boothNewListingsProvider(boothId));
    ref.invalidate(
      boothCatalogListingsProvider((
        boothId: boothId,
        categoryId: _selectedCategoryId,
        sort: 'newest',
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boothAsync = ref.watch(publicBoothProvider(widget.boothSlug));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: boothAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(publicBoothProvider(widget.boothSlug)),
        ),
        data: (booth) {
          if (booth == null) {
            return const AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'فروشگاه یافت نشد',
              subtitle: 'این فروشگاه غیرفعال، مسدود یا حذف شده است.',
            );
          }

          final session = ref.watch(authSessionProvider).valueOrNull;
          final isOwner = session != null && booth.ownerId == session.user.id;
          final phone = booth.publicPhone;
          final catalogQuery = (
            boothId: booth.id,
            categoryId: _selectedCategoryId,
            sort: 'newest',
          );
          final listingsAsync = ref.watch(boothCatalogListingsProvider(catalogQuery));
          final bestsellersAsync = ref.watch(boothBestsellersProvider(booth.id));
          final newAsync = ref.watch(boothNewListingsProvider(booth.id));
          final summaryAsync = ref.watch(boothSummaryProvider(widget.boothSlug));

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _refresh(booth.id),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.canvas,
                  surfaceTintColor: Colors.transparent,
                  title: Text(booth.name),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'اشتراک‌گذاری فروشگاه',
                      onPressed: () => _share(booth),
                    ),
                    if (!isOwner)
                      PopupMenuButton<String>(
                        tooltip: 'گزارش تخلف',
                        icon: const Icon(Icons.flag_outlined),
                        onSelected: (value) {
                          final ReportTarget? target = switch (value) {
                            'booth' => ReportTarget(
                                type: ReportTargetType.booth,
                                targetId: booth.id,
                                label: booth.name,
                              ),
                            'user' when booth.ownerId != null => ReportTarget(
                                type: ReportTargetType.user,
                                targetId: booth.ownerId!,
                                label: booth.name,
                              ),
                            _ => null,
                          };
                          if (target != null) openReportScreen(context, target);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'booth',
                            child: Text('گزارش فروشگاه'),
                          ),
                          if (booth.ownerId != null)
                            const PopupMenuItem(
                              value: 'user',
                              child: Text('گزارش فروشنده'),
                            ),
                        ],
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      BoothHeader(
                        booth: booth,
                        onPhoneTap: phone == null
                            ? null
                            : () {
                                if (session == null) {
                                  context.push(RouteNames.login);
                                } else {
                                  _callPhone(phone);
                                }
                              },
                      ),
                      _BoothStatsRow(summaryAsync: summaryAsync),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                        child: FollowButton(
                          boothId: booth.id,
                          boothSlug: booth.slug,
                          isOwner: isOwner,
                        ),
                      ),
                      if (!isOwner) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                          child: Row(
                            children: [
                              if (phone != null)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: session == null
                                        ? () => context.push(RouteNames.login)
                                        : () => _callPhone(phone),
                                    icon: const Icon(Icons.phone_outlined),
                                    label: const Text('تماس'),
                                  ),
                                ),
                              if (phone != null) const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: session == null
                                      ? () => context.push(RouteNames.login)
                                      : () => _startChat(context, booth.id, booth.name),
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('گفتگو'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
                ..._sectionListings(
                  title: 'پرفروش‌ها',
                  subtitle: 'محبوب‌ترین محصولات این فروشگاه',
                  asyncList: bestsellersAsync,
                ),
                ..._sectionListings(
                  title: 'جدیدها',
                  subtitle: 'آخرین محصولات اضافه‌شده',
                  asyncList: newAsync,
                ),
                SliverToBoxAdapter(
                  child: summaryAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (summary) {
                      if (summary == null || summary.categories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.sm,
                          AppSpacing.screen,
                          AppSpacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دسته‌بندی‌های فروشگاه',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                FilterChip(
                                  label: const Text('همه'),
                                  selected: _selectedCategoryId == null,
                                  onSelected: (_) => setState(() => _selectedCategoryId = null),
                                ),
                                ...summary.categories.map(
                                  (c) => FilterChip(
                                    label: Text(c.name),
                                    selected: _selectedCategoryId == c.id,
                                    onSelected: (_) => setState(() {
                                      _selectedCategoryId =
                                          _selectedCategoryId == c.id ? null : c.id;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: RahmaniSectionHeader(
                    title: 'محصولات فروشگاه',
                    subtitle: 'لیست فعال فروشنده',
                  ),
                ),
                listingsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: AppLoadingIndicator(),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: AppAsyncError(
                        error: e,
                        onRetry: () => ref.invalidate(
                          boothCatalogListingsProvider(catalogQuery),
                        ),
                      ),
                    ),
                  ),
                  data: (listings) {
                    if (listings.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: AppEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'محصولی موجود نیست',
                            subtitle: 'در این دسته یا فروشگاه محصول فعالی نیست.',
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        AppSpacing.lg,
                      ),
                      sliver: SliverList.separated(
                        itemCount: listings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return ListingCard.fromPublic(
                            listing,
                            onTap: () =>
                                context.push(RouteNames.productDetail(listing.id)),
                          );
                        },
                      ),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.xl,
                    ),
                    child: ReviewList.booth(boothId: booth.id),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _sectionListings({
    required String title,
    required String subtitle,
    required AsyncValue<List<PublicListingEntity>> asyncList,
  }) {
    return asyncList.when(
      loading: () => const <Widget>[],
      error: (_, _) => const <Widget>[],
      data: (listings) {
        if (listings.isEmpty) return const <Widget>[];
        return [
          SliverToBoxAdapter(
            child: RahmaniSectionHeader(title: title, subtitle: subtitle),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                itemCount: listings.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return SizedBox(
                    width: 152,
                    child: ListingCard.fromPublic(
                      listing,
                      compact: true,
                      onTap: () =>
                          context.push(RouteNames.productDetail(listing.id)),
                    ),
                  );
                },
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _BoothStatsRow extends StatelessWidget {
  const _BoothStatsRow({required this.summaryAsync});

  final AsyncValue<BoothSummaryEntity?> summaryAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.xs,
      ),
      child: summaryAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (summary) {
          if (summary == null) return const SizedBox.shrink();
          return Row(
            children: [
              if (summary.reviewCount > 0)
                Expanded(
                  child: StarRatingDisplay(
                    rating: summary.averageRating,
                    reviewCount: summary.reviewCount,
                  ),
                )
              else
                Text(
                  'بدون امتیاز',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('${summary.productCount} محصول'),
            ],
          );
        },
      ),
    );
  }
}