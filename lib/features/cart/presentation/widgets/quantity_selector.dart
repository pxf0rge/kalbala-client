import 'package:flutter/material.dart';

/// Increment/decrement control for cart item quantity.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
    super.key,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > 1;
    final canIncrease = quantity < maxQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: canDecrease ? () => onChanged(quantity - 1) : null,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '$quantity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: canIncrease ? () => onChanged(quantity + 1) : null,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
