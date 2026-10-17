import 'package:flutter/material.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';

/// Visual indicator for payment status.
class PaymentStatusIndicator extends StatelessWidget {
  const PaymentStatusIndicator({
    required this.status,
    super.key,
  });

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      PaymentStatus.completed => (Icons.check_circle, Colors.green),
      PaymentStatus.failed => (Icons.error_outline, Colors.red),
      PaymentStatus.processing => (Icons.hourglass_top, Colors.orange),
      PaymentStatus.pending => (Icons.schedule, Colors.orange),
      PaymentStatus.refunded => (Icons.replay, Colors.blueGrey),
    };

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(status.label),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }
}
