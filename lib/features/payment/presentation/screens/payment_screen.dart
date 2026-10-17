import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/payment/presentation/providers/payment_provider.dart';
import 'package:rahmani_project/features/payment/presentation/widgets/gateway_selector.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Online payment screen with gateway selection.
/// Gateways are temporarily unavailable («به زودی»).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Scaffold(
      appBar: AppBar(title: const Text('پرداخت آنلاین')),
      body: orderAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('سفارش یافت نشد'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'مبلغ قابل پرداخت: ${priceFormat.format(order.totalAmount)} ${AppConstants.currencySymbol}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text('پرداخت آنلاین', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GatewaySelector(
                selected: paymentState.selectedGateway,
                onChanged: ref.read(paymentProvider.notifier).selectGateway,
              ),
              const SizedBox(height: 96),
            ],
          );
        },
      ),
      bottomNavigationBar: orderAsync.maybeWhen(
        data: (order) => order == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: null,
                    child: const Text('به زودی'),
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
