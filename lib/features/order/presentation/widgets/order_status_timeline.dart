import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';

/// Timeline of seller order status changes.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({required this.history, super.key});

  final List<OrderStatusHistoryEntity> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('تاریخچه‌ای ثبت نشده است.');
    }

    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'fa');

    return Column(
      children: history.map((entry) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history),
          title: Text(entry.toStatus.labelFa),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.fromStatus != null) Text('از ${entry.fromStatus!.labelFa}'),
              if (entry.trackingNumber != null) Text('رهگیری: ${entry.trackingNumber}'),
              Text(dateFormat.format(entry.createdAt)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Tracking number display widget.
class TrackingInfo extends StatelessWidget {
  const TrackingInfo({
    required this.trackingNumber,
    this.shippingProvider,
    this.shipmentStatus,
    super.key,
  });

  final String trackingNumber;
  final String? shippingProvider;
  final String? shipmentStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_shipping_outlined),
        title: const Text('کد رهگیری'),
        subtitle: Text([
          if (shipmentStatus != null && shipmentStatus!.isNotEmpty) _statusLabel(shipmentStatus!),
          if (shippingProvider != null && shippingProvider!.isNotEmpty) shippingProvider!,
          trackingNumber,
        ].join(' — ')),
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'در انتظار ارسال',
      'shipped' => 'ارسال شده',
      'in_transit' => 'در مسیر',
      'delivered' => 'تحویل شده',
      'cancelled' => 'لغو شده',
      _ => status,
    };
  }
}
