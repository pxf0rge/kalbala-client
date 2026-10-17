import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';
import 'package:rahmani_project/features/cart/presentation/widgets/cart_booth_group.dart';
import 'package:rahmani_project/features/cart/presentation/widgets/cart_summary_bar.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Multi-booth shopping cart screen.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final cartAsync = ref.watch(cartProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('سبد خرید')),
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
      appBar: AppBar(
        title: const Text('سبد خرید'),
        actions: [
          cartAsync.maybeWhen(
            data: (cart) => cart.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'خالی کردن سبد',
                    onPressed: () => _confirmClear(context, ref),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(
          error: e,
          onRetry: () => ref.invalidate(cartProvider),
        ),
        data: (cart) {
          if (cart.isEmpty) {
            return const AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'سبد خرید خالی است',
              subtitle: 'محصولات مورد نظر را از فروشگاه‌ها اضافه کنید.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(cartProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.boothGroups.map(
                  (group) => CartBoothGroup(
                    group: group,
                    onQuantityChanged: (cartItemId, quantity) async {
                      final ok = await ref.read(cartProvider.notifier).updateQuantity(
                            cartItemId: cartItemId,
                            quantity: quantity,
                          );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('موجودی کافی نیست.')),
                        );
                      }
                    },
                    onRemove: (cartItemId) =>
                        ref.read(cartProvider.notifier).removeItem(cartItemId),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (cart) => cart.isEmpty
            ? null
            : CartSummaryBar(
                total: cart.total,
                itemCount: cart.itemCount,
                hasStockIssues: cart.hasStockIssues,
              ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خالی کردن سبد'),
        content: const Text('آیا از حذف همه اقلام سبد خرید مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('خالی کردن'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cartProvider.notifier).clearCart();
    }
  }
}
