import 'package:flutter/material.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';

/// Status badge for orders and seller orders.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge._({required this.label, required this.color});

  final String label;
  final Color color;

  factory OrderStatusBadge.orderStatus(OrderStatus status) {
    final color = switch (status) {
      OrderStatus.pendingPayment => Colors.orange,
      OrderStatus.paymentFailed => Colors.red,
      OrderStatus.confirmed => Colors.blue,
      OrderStatus.cancelled => Colors.grey,
      OrderStatus.completed => Colors.green,
    };
    return OrderStatusBadge._(label: status.labelFa, color: color);
  }

  factory OrderStatusBadge.sellerStatus(SellerOrderStatus status) {
    final color = switch (status) {
      SellerOrderStatus.pending => Colors.orange,
      SellerOrderStatus.reviewing => Colors.deepOrange,
      SellerOrderStatus.confirmed => Colors.blue,
      SellerOrderStatus.processing => Colors.indigo,
      SellerOrderStatus.shipped => Colors.teal,
      SellerOrderStatus.delivered => Colors.green,
      SellerOrderStatus.cancelled => Colors.grey,
      SellerOrderStatus.refunded => Colors.red,
    };
    return OrderStatusBadge._(label: status.labelFa, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
