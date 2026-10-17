import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';

/// Select delivery address for checkout.
class AddressSelector extends StatelessWidget {
  const AddressSelector({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelected,
    super.key,
  });

  final List<AddressEntity> addresses;
  final String? selectedAddressId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('آدرسی ثبت نشده است.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(RouteNames.profileAddressAdd),
                child: const Text('افزودن آدرس'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: addresses.map((address) {
        final selected = address.id == selectedAddressId;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            value: address.id,
            groupValue: selectedAddressId,
            onChanged: (value) {
              if (value != null) onSelected(value);
            },
            title: Text(address.label),
            subtitle: Text(
              '${address.recipientName} — ${address.fullAddress}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondary: address.isDefault
                ? Chip(
                    label: const Text('پیش‌فرض', style: TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
