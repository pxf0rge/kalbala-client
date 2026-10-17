import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/listing_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Seller screen to manage listings for a booth.
class BoothListingsScreen extends ConsumerWidget {
  const BoothListingsScreen({required this.boothId, super.key});

  final String boothId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(boothListingsProvider(boothId));

    return Scaffold(
      appBar: AppBar(title: const Text('لیستینگ‌های فروشگاه')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.sellerBoothListingAdd(boothId)),
        icon: const Icon(Icons.add),
        label: const Text('افزودن لیستینگ'),
      ),
      body: listingsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری لیستینگ‌ها...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (listings) {
          if (listings.isEmpty) {
            return const AppEmptyState(
              icon: Icons.sell_outlined,
              title: 'لیستینگی ثبت نشده',
              subtitle: 'محصولات کاتالوگ را به این فروشگاه اضافه کنید و قیمت و موجودی تعیین کنید.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(boothListingsProvider(boothId).notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingCard.fromEntity(
                  listing,
                  onTap: () => context.push(RouteNames.sellerBoothListingEdit(boothId, listing.id)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push(RouteNames.sellerBoothListingEdit(boothId, listing.id));
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('حذف لیستینگ'),
                            content: Text('«${listing.productName ?? 'محصول'}» از فروشگاه حذف شود؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('انصراف'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await ref.read(boothListingsProvider(boothId).notifier).remove(listing.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                      const PopupMenuItem(value: 'delete', child: Text('حذف')),
                    ],
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