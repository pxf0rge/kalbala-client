import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Buyer order list screen.
class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
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
      ref.read(myOrdersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final ordersAsync = ref.watch(myOrdersProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('سفارش‌ها')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لطفاً وارد حساب کاربری شوید.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('ورود'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('سفارش‌ها')),
      body: ordersAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
        data: (page) {
          if (page.items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'سفارشی ثبت نشده',
              subtitle: 'سفارش‌های شما اینجا نمایش داده می‌شوند.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(myOrdersProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: page.items.length + (page.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= page.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final order = page.items[index];
                return OrderCard(
                  order: order,
                  onTap: () => context.push(RouteNames.orderDetail(order.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
