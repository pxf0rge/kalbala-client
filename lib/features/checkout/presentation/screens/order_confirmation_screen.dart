import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/presentation/providers/checkout_provider.dart';

/// Order confirmation after successful checkout.
class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra;
    final result = extra is PlaceOrderResultEntity ? extra : null;
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Scaffold(
      appBar: AppBar(title: const Text('تأیید سفارش')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'سفارش شما ثبت شد',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (result != null) ...[
              _InfoRow(label: 'شماره سفارش', value: result.orderNumber),
              _InfoRow(
                label: 'مبلغ کل',
                value: '${priceFormat.format(result.totalAmount)} ${AppConstants.currencySymbol}',
              ),
              _InfoRow(label: 'روش پرداخت', value: result.paymentMethod.label),
              if (result.requiresOnlinePayment) ...[
                const SizedBox(height: 16),
                Text(
                  'برای تکمیل خرید، پرداخت آنلاین را انجام دهید. مهلت پرداخت: ۳۰ دقیقه.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  'سفارش شما تأیید شد و در حال پردازش است.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ] else
              _InfoRow(label: 'شناسه سفارش', value: orderId),
            const Spacer(),
            if (result?.requiresOnlinePayment == true)
              FilledButton(
                onPressed: () => context.push(RouteNames.orderPay(orderId)),
                child: const Text('پرداخت آنلاین'),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                ref.read(checkoutProvider.notifier).reset();
                context.go(RouteNames.orderDetail(orderId));
              },
              child: const Text('مشاهده جزئیات سفارش'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ref.read(checkoutProvider.notifier).reset();
                context.go(RouteNames.home);
              },
              child: const Text('بازگشت به خانه'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RouteNames.orders),
              child: const Text('لیست سفارش‌ها'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}