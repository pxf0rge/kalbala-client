import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/listing_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Public buyer view of a booth storefront.
class PublicBoothScreen extends ConsumerWidget {
  const PublicBoothScreen({required this.boothSlug, super.key});

  final String boothSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(publicBoothListingsProvider(boothSlug));

    return Scaffold(
      appBar: AppBar(title: Text('فروشگاه: $boothSlug')),
      body: listingsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(error: e),
        data: (listings) {
          if (listings.isEmpty) {
            return const AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'محصولی موجود نیست',
              subtitle: 'این فروشگاه هنوز محصول فعالی ندارد.',
            );
          }

          final boothName = listings.first.boothName;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(publicBoothListingsProvider(boothSlug)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(boothName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                ...listings.map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListingCard.fromPublic(
                      listing,
                      onTap: () => context.push(RouteNames.productDetail(listing.id)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}