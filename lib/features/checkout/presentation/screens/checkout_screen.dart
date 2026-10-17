import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';
import 'package:rahmani_project/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:rahmani_project/features/checkout/presentation/widgets/address_selector.dart';
import 'package:rahmani_project/features/checkout/presentation/widgets/booth_order_group.dart';
import 'package:rahmani_project/features/checkout/presentation/widgets/checkout_summary.dart';
import 'package:rahmani_project/features/checkout/presentation/widgets/payment_method_selector.dart';
import 'package:rahmani_project/features/home/domain/entities/analytics_enums.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/features/shipping/presentation/providers/shipping_provider.dart';
import 'package:rahmani_project/features/shipping/presentation/widgets/shipping_cost_breakdown.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Checkout flow: address, payment method, order summary.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).initDefaultAddress();
      _noteController.text = ref.read(checkoutProvider).buyerNote;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final cartAsync = ref.watch(cartProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final checkoutState = ref.watch(checkoutProvider);

    // When addresses finish loading, pick default once.
    ref.listen(addressesProvider, (previous, next) {
      final list = next.valueOrNull;
      if (list != null && list.isNotEmpty) {
        ref.read(checkoutProvider.notifier).initDefaultAddress();
      }
    });

    final addressId = checkoutState.selectedAddressId;
    if (addressId != null) {
      ref.watch(checkoutShippingPreviewProvider(addressId));
    }

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('پرداخت')),
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
      appBar: AppBar(title: const Text('پرداخت')),
      body: cartAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (cart) {
          if (cart.isEmpty) {
            return const AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'سبد خرید خالی است',
              subtitle: 'ابتدا محصولی به سبد اضافه کنید.',
            );
          }

          final summary = ref.read(checkoutProvider.notifier).summary();
          final addresses = addressesAsync.valueOrNull ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('آدرس تحویل', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AddressSelector(
                addresses: addresses,
                selectedAddressId: checkoutState.selectedAddressId,
                onSelected: ref.read(checkoutProvider.notifier).selectAddress,
              ),
              const SizedBox(height: 24),
              Text('روش پرداخت', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              PaymentMethodSelector(
                selected: checkoutState.paymentMethod,
                onChanged: ref.read(checkoutProvider.notifier).selectPaymentMethod,
              ),
              const SizedBox(height: 24),
              Text('توضیحات سفارش', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'مثلاً ساعت تحویل، توضیحات برای فروشنده… (اختیاری)',
                  border: OutlineInputBorder(),
                ),
                onChanged: ref.read(checkoutProvider.notifier).setBuyerNote,
              ),
              const SizedBox(height: 24),
              Text('خلاصه سفارش', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (summary.hasStockIssues)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'برخی اقلام موجودی کافی ندارند. لطفاً سبد را بررسی کنید.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ...summary.boothGroups.map((group) => BoothOrderGroup(group: group)),
              const SizedBox(height: 16),
              ShippingCostBreakdown(summary: summary, city: summary.city),
              const SizedBox(height: 96),
            ],
          );
        },
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (cart) => cart.isEmpty
            ? null
            : Builder(
                builder: (context) {
                  final summary = ref.read(checkoutProvider.notifier).summary();
                  return CheckoutSummary(
                    summary: summary,
                    isLoading: checkoutState.isPlacingOrder,
                    canSubmit: checkoutState.selectedAddressId != null && !summary.hasStockIssues,
                    onPlaceOrder: () => _placeOrder(context),
                  );
                },
              ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final result = await ref.read(checkoutProvider.notifier).submitOrder();
    if (!context.mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ثبت سفارش ناموفق بود. دوباره تلاش کنید.')),
      );
      return;
    }

    await ref.read(trackEventProvider).call(
          eventType: AnalyticsEventType.purchase,
          entityType: 'order',
          entityId: result.orderId,
        );

    if (!context.mounted) return;

    context.go(
      RouteNames.checkoutConfirmation(result.orderId),
      extra: result,
    );
  }
}