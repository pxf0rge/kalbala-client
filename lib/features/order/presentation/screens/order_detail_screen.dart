import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/chat/presentation/providers/chat_provider.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_badge.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_timeline.dart';
import 'package:rahmani_project/features/payment/presentation/widgets/payment_status_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buyer order detail with seller order groups.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));
    final priceFormat = NumberFormat('#,##0', 'fa');
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'fa');

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات سفارش')),
      body: detailAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (detail) {
          if (detail == null) return const Center(child: Text('سفارش یافت نشد'));

          final address = detail.shippingAddress;
          final addressText = [
            address['recipient_name'],
            address['phone'],
            address['city'],
            address['district'],
            address['street'],
          ].whereType<String>().where((s) => s.isNotEmpty).join('، ');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(detail.orderNumber, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              OrderStatusBadge.orderStatus(detail.status),
              const SizedBox(height: 16),
              Text('مبلغ کل: ${priceFormat.format(detail.totalAmount)} ${AppConstants.currencySymbol}'),
              Text('روش پرداخت: ${detail.paymentMethod.label}'),
              Text('تاریخ: ${dateFormat.format(detail.createdAt)}'),
              if (detail.expiresAt != null)
                Text('مهلت پرداخت: ${dateFormat.format(detail.expiresAt!)}'),
              if (detail.payment != null) ...[
                const SizedBox(height: 16),
                Text('وضعیت پرداخت', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                PaymentStatusIndicator(status: detail.payment!.status),
              ],
              if (detail.canPayOnline) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push(RouteNames.orderPay(orderId)),
                  child: Text(
                    detail.status == OrderStatus.paymentFailed
                        ? 'تلاش مجدد پرداخت'
                        : 'پرداخت آنلاین',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text('آدرس تحویل', style: Theme.of(context).textTheme.titleMedium),
              Text(addressText),
              if (detail.buyerNote != null && detail.buyerNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('توضیحات خریدار', style: Theme.of(context).textTheme.titleMedium),
                Text(detail.buyerNote!),
              ],
              const SizedBox(height: 24),
              Text('سفارش‌های فروشگاه‌ها', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...detail.sellerOrders.map((sellerOrder) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(sellerOrder.boothName)),
                            OrderStatusBadge.sellerStatus(sellerOrder.status),
                          ],
                        ),
                        if (sellerOrder.boothPhone != null &&
                            sellerOrder.boothPhone!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _callBooth(context, sellerOrder.boothPhone!),
                                  icon: const Icon(Icons.phone_outlined, size: 18),
                                  label: const Text('تماس'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => _chatBooth(
                                    context,
                                    ref,
                                    boothId: sellerOrder.boothId,
                                    boothName: sellerOrder.boothName,
                                  ),
                                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                  label: const Text('گفتگو'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: () => _chatBooth(
                              context,
                              ref,
                              boothId: sellerOrder.boothId,
                              boothName: sellerOrder.boothName,
                            ),
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text('گفتگو با فروشنده'),
                          ),
                        ],
                        const SizedBox(height: 8),
                        ...sellerOrder.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.productName}${item.variantName != null ? ' (${item.variantName})' : ''} — ${item.quantity} × ${priceFormat.format(item.unitPrice)}',
                                ),
                                if (item.hasReview)
                                  Text(
                                    'نظر ثبت شد',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                    ),
                                  )
                                else if (item.canReview)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final submitted = await context.push<bool>(
                                        RouteNames.writeReview(item.id),
                                        extra: item.productName,
                                      );
                                      if (submitted == true) {
                                        ref.invalidate(orderDetailProvider(orderId));
                                      }
                                    },
                                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                                    label: const Text('ثبت نظر'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جمع: ${priceFormat.format(sellerOrder.total)} ${AppConstants.currencySymbol}',
                        ),
                        if (_trackingNumber(sellerOrder) != null) ...[
                          const SizedBox(height: 8),
                          TrackingInfo(
                            trackingNumber: _trackingNumber(sellerOrder)!,
                            shippingProvider: _shippingProvider(sellerOrder),
                            shipmentStatus: sellerOrder.shipment?.status,
                          ),
                        ],
                        if (sellerOrder.statusHistory.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('تاریخچه', style: Theme.of(context).textTheme.titleSmall),
                          OrderStatusTimeline(history: sellerOrder.statusHistory),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

String? _trackingNumber(SellerOrderEntity sellerOrder) {
  return sellerOrder.shipment?.trackingNumber ?? sellerOrder.trackingNumber;
}

String? _shippingProvider(SellerOrderEntity sellerOrder) {
  return sellerOrder.shipment?.provider ?? sellerOrder.shippingProvider;
}

Future<void> _callBooth(BuildContext context, String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri(scheme: 'tel', path: cleaned);
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('امکان برقراری تماس وجود ندارد')),
    );
  }
}

Future<void> _chatBooth(
  BuildContext context,
  WidgetRef ref, {
  required String boothId,
  required String boothName,
}) async {
  final result = await ref.read(startConversationProvider).call(boothId);
  if (!context.mounted) return;
  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    ),
    (conversationId) {
      ref.invalidate(conversationsProvider);
      context.push(RouteNames.chatDetail(conversationId), extra: boothName);
    },
  );
}