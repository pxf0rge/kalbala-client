import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/commission/domain/entities/commission_entities.dart';
import 'package:rahmani_project/features/commission/presentation/widgets/seller_payout_breakdown.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_badge.dart';
import 'package:rahmani_project/features/order/presentation/widgets/order_status_timeline.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Seller order detail with status management.
class SellerOrderDetailScreen extends ConsumerStatefulWidget {
  const SellerOrderDetailScreen({required this.sellerOrderId, super.key});

  final String sellerOrderId;

  @override
  ConsumerState<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends ConsumerState<SellerOrderDetailScreen> {
  final _trackingController = TextEditingController();
  bool _updating = false;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(sellerOrderDetailProvider(widget.sellerOrderId));
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت سفارش')),
      body: detailAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (detail) {
          if (detail == null) return const Center(child: Text('سفارش یافت نشد'));

          final nextStatus = detail.status.nextStatus;
          final needsTracking = nextStatus == SellerOrderStatus.shipped;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(detail.orderNumber, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              OrderStatusBadge.sellerStatus(detail.status),
              const SizedBox(height: 16),
              Text('فروشگاه: ${detail.boothName}'),
              Text('خریدار: ${detail.buyerName}'),
              Text('تلفن: ${detail.buyerPhone}'),
              if (detail.buyerNote != null && detail.buyerNote!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('یادداشت خریدار', style: Theme.of(context).textTheme.titleMedium),
                Text(detail.buyerNote!),
              ],
              const SizedBox(height: 16),
              Text('اقلام', style: Theme.of(context).textTheme.titleMedium),
              ...detail.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text(item.variantName ?? ''),
                  trailing: Text('${item.quantity} × ${priceFormat.format(item.unitPrice)}'),
                ),
              ),
              const Divider(),
              SellerPayoutBreakdown(
                breakdown: CommissionBreakdown.fromSellerOrder(
                  subtotal: detail.subtotal,
                  commissionAmount: detail.commissionAmount,
                  sellerPayout: detail.sellerPayout,
                  shippingCost: detail.shippingCost,
                  commissionEnabled: detail.commissionEnabled,
                  commissionRatePercent: detail.commissionRatePercent,
                ),
              ),
              if (detail.trackingNumber != null) ...[
                const SizedBox(height: 16),
                TrackingInfo(
                  trackingNumber: detail.trackingNumber!,
                  shippingProvider: detail.shippingProvider,
                ),
              ],
              if (nextStatus != null) ...[
                const SizedBox(height: 24),
                if (needsTracking) ...[
                  TextField(
                    controller: _trackingController,
                    decoration: const InputDecoration(
                      labelText: 'کد رهگیری',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _updating ? null : () => _advanceStatus(detail.status),
                  child: _updating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('تغییر به: ${nextStatus.labelFa}'),
                ),
                if (detail.status == SellerOrderStatus.pending) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _updating
                        ? null
                        : () => _advanceTo(SellerOrderStatus.confirmed),
                    child: const Text('تأیید مستقیم (بدون بررسی)'),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Text('تاریخچه وضعیت', style: Theme.of(context).textTheme.titleMedium),
              OrderStatusTimeline(history: detail.statusHistory),
            ],
          );
        },
      ),
    );
  }

  Future<void> _advanceStatus(SellerOrderStatus currentStatus) async {
    final nextStatus = currentStatus.nextStatus;
    if (nextStatus == null) return;
    await _advanceTo(nextStatus);
  }

  Future<void> _advanceTo(SellerOrderStatus nextStatus) async {
    setState(() => _updating = true);
    final ok = await ref.read(sellerOrdersProvider.notifier).advanceStatus(
          sellerOrderId: widget.sellerOrderId,
          newStatus: nextStatus,
          trackingNumber: nextStatus == SellerOrderStatus.shipped
              ? _trackingController.text.trim()
              : null,
        );
    if (!mounted) return;
    setState(() => _updating = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('به‌روزرسانی وضعیت ناموفق بود.')),
      );
      return;
    }

    ref.invalidate(sellerOrderDetailProvider(widget.sellerOrderId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('وضعیت سفارش به‌روزرسانی شد.')),
    );
  }
}