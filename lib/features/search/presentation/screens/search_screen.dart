import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/search/domain/entities/search_entities.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/presentation/providers/search_provider.dart';
import 'package:rahmani_project/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:rahmani_project/shared/widgets/rahmani_ui.dart';

/// Search entry screen with history, live typeahead, and submit-to-results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialTab, super.key});

  /// When opened from «جستجوی فروشگاه» / «جستجوی محصول» shortcuts.
  final SearchTab? initialTab;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTab;
    if (tab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(searchFiltersProvider.notifier).prepareForTab(tab);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(searchFiltersProvider.notifier).updateQuery(value);
    });
  }

  Future<void> _submit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && trimmed.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل ۲ حرف برای جستجو وارد کنید')),
      );
      return;
    }
    ref.read(searchFiltersProvider.notifier).updateQuery(trimmed);
    await _recordHistory(trimmed);
    if (mounted) context.push(RouteNames.searchResults);
  }

  Future<void> _recordHistory(String query) async {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null || query.trim().length < 2) return;
    await ref.read(searchHistoryProvider.notifier).add(query);
  }

  Future<void> _onSuggestionTap(SearchSuggestion suggestion) async {
    _controller.text = suggestion.queryText;

    if (suggestion.type == SearchSuggestionType.booth) {
      ref.read(searchFiltersProvider.notifier).prepareForTab(SearchTab.booths);
    } else if (suggestion.type == SearchSuggestionType.category &&
        suggestion.targetId != null) {
      ref.read(searchFiltersProvider.notifier).prepareForTab(SearchTab.products);
      ref.read(searchFiltersProvider.notifier).applyFilters(
            categoryId: suggestion.targetId,
          );
    } else {
      ref.read(searchFiltersProvider.notifier).prepareForTab(SearchTab.products);
    }

    await _submit(suggestion.queryText);
  }

  void _onPopularOrHistoryTap(String query) {
    _controller.text = query;
    _submit(query);
  }

  IconData _iconFor(SearchSuggestionType type) {
    return switch (type) {
      SearchSuggestionType.product => Icons.inventory_2_outlined,
      SearchSuggestionType.booth => Icons.storefront_outlined,
      SearchSuggestionType.category => Icons.category_outlined,
      SearchSuggestionType.history => Icons.history_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final historyAsync = ref.watch(searchHistoryProvider);
    final popularAsync = ref.watch(popularSearchesProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);
    final filters = ref.watch(searchFiltersProvider);
    final history = historyAsync.valueOrNull ?? const <SearchHistoryEntry>[];
    final theme = Theme.of(context);
    final isBooths = filters.tab == SearchTab.booths;
    final showTypeahead = filters.query.trim().length >= 2;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(isBooths ? 'جستجوی فروشگاه' : 'جستجوی محصول'),
        backgroundColor: AppColors.canvas,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          SegmentedButton<SearchTab>(
            segments: SearchTab.values
                .map((tab) => ButtonSegment(value: tab, label: Text(tab.labelFa)))
                .toList(),
            selected: {filters.tab},
            onSelectionChanged: (selection) {
              ref.read(searchFiltersProvider.notifier).updateTab(selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppSearchBar(
            controller: _controller,
            autofocus: true,
            hintText: isBooths ? 'نام فروشگاه را جستجو کنید…' : 'نام محصول را جستجو کنید…',
            onChanged: _onQueryChanged,
            onSubmitted: _submit,
          ),
          if (showTypeahead) ...[
            RahmaniSectionHeader(
              title: 'پیشنهادها',
              subtitle: 'نتایج هم‌زمان با تایپ',
              padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, AppSpacing.sm),
            ),
            suggestionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (suggestions) {
                if (suggestions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      'پیشنهادی یافت نشد — Enter بزنید تا همه نتایج را ببینید',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  );
                }
                return Material(
                  color: AppColors.surfaceRaised,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(color: AppColors.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < suggestions.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: AppColors.hairline),
                        ListTile(
                          dense: true,
                          leading: Icon(
                            _iconFor(suggestions[i].type),
                            color: AppColors.primary,
                          ),
                          title: Text(suggestions[i].label),
                          subtitle: suggestions[i].subtitle != null
                              ? Text(suggestions[i].subtitle!)
                              : null,
                          onTap: () => _onSuggestionTap(suggestions[i]),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(
              onPressed: () => _submit(_controller.text),
              child: const Text('مشاهده همه نتایج'),
            ),
          ] else ...[
            popularAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (popular) {
                if (popular.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RahmaniSectionHeader(
                      title: 'پیشنهادهای جستجو',
                      subtitle: 'محبوب‌ترین جستجوها',
                      padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, AppSpacing.sm),
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: popular.map((entry) {
                        return ActionChip(
                          avatar: const Icon(
                            Icons.trending_up_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(entry.query),
                          backgroundColor: AppColors.surfaceRaised,
                          side: BorderSide(color: AppColors.hairline),
                          onPressed: () => _onPopularOrHistoryTap(entry.query),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            if (session != null) ...[
              if (history.isNotEmpty) ...[
                RahmaniSectionHeader(
                  title: 'تاریخچه جستجو',
                  actionLabel: 'پاک کردن',
                  onAction: () async {
                    await ref.read(searchHistoryProvider.notifier).clearAll();
                  },
                  padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, AppSpacing.sm),
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
                      for (var i = 0; i < history.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: AppColors.hairline),
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.history_rounded, color: AppColors.inkMuted,
                          ),
                          title: Text(history[i].query),
                          trailing: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            tooltip: 'حذف',
                            onPressed: () => ref
                                .read(searchHistoryProvider.notifier)
                                .remove(history[i].id),
                          ),
                          onTap: () => _onPopularOrHistoryTap(history[i].query),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              Text(
                isBooths ? 'نام فروشگاه را وارد کنید' : 'نام محصول را وارد کنید',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'حداقل ۲ حرف تایپ کنید تا پیشنهادها ظاهر شوند',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }
}