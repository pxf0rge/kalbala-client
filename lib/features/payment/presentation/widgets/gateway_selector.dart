import 'package:flutter/material.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';

/// Gateway selection for online payment.
/// All gateways are temporarily unavailable («به زودی»).
class GatewaySelector extends StatelessWidget {
  const GatewaySelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final PaymentGateway selected;
  final ValueChanged<PaymentGateway> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: PaymentGateway.values.map((gateway) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Opacity(
            opacity: 0.55,
            child: RadioListTile<PaymentGateway>(
              value: gateway,
              groupValue: selected,
              onChanged: null,
              title: Text(gateway.label),
              subtitle: Text(
                'به زودی',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
