import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/order/presentation/widgets/seller_order_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Seller order list screen.
class SellerOrderListScreen extends ConsumerStatefulWidget {
  const SellerOrderListScreen({super.key});

  @override
  ConsumerState<SellerOrderListScreen> createState() => _SellerOrderListScreenState();
}

class _SellerOrderListScreenState extends ConsumerState<SellerOrderListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (shouldLoadMoreFromScroll(
      pixels: _scrollController.position.pixels,
      maxScrollExtent: _scrollController.position.maxScrollExtent,
    )) {
      ref.read(sellerOrdersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('سفارش‌های فروش')),
      body: ordersAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(sellerOrdersProvider),
        ),
        data: (page) {
          if (page.items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inventory_outlined,
              title: 'سفارشی دریافت نشده',
              subtitle: 'سفارش‌های مشتریان اینجا نمایش داده می‌شوند.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(sellerOrdersProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: page.items.length + (page.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index >= page.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final order = page.items[index];
                return SellerOrderCard(
                  order: order,
                  onTap: () => context.push(RouteNames.sellerOrderDetail(order.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}