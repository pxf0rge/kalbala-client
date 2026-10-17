import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:rahmani_project/features/search/presentation/widgets/search_result_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// User's saved favorite listings.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('علاقه‌مندی‌ها')),
      body: favoritesAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'علاقه‌مندی‌ای ثبت نشده',
              subtitle: 'محصولات مورد علاقه را از صفحه جزئیات محصول ذخیره کنید.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(favoritesProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final listing = favorites[index];
                return Dismissible(
                  key: ValueKey(listing.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => ref.read(favoritesProvider.notifier).remove(listing.id),
                  child: SearchResultCard(listing: listing),
                );
              },
            ),
          );
        },
      ),
    );
  }
}