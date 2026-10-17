import 'package:flutter/material.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';

/// Online vs COD payment method selector.
/// Only COD is enabled for now; online shows «به زودی».
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final CheckoutPaymentMethod selected;
  final ValueChanged<CheckoutPaymentMethod> onChanged;

  static bool isEnabled(CheckoutPaymentMethod method) =>
      method == CheckoutPaymentMethod.cod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: CheckoutPaymentMethod.values.map((method) {
        final enabled = isEnabled(method);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: RadioListTile<CheckoutPaymentMethod>(
              value: method,
              groupValue: selected,
              onChanged: enabled
                  ? (value) {
                      if (value != null) onChanged(value);
                    }
                  : null,
              title: Text(method.label),
              subtitle: Text(
                enabled
                    ? 'پرداخت هنگام تحویل کالا'
                    : 'به زودی',
                style: enabled
                    ? null
                    : theme.textTheme.bodySmall?.copyWith(
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
