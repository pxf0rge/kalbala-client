import 'package:flutter/material.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';

/// Card displaying a delivery address.
class AddressCard extends StatelessWidget {
  const AddressCard({
    required this.address,
    this.onTap,
    this.onSetDefault,
    this.onDelete,
    super.key,
  });

  final AddressEntity address;
  final VoidCallback? onTap;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'پیش‌فرض',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(address.recipientName),
              Text(PhoneUtils.formatForDisplay(address.phone)),
              const SizedBox(height: 4),
              Text(
                address.fullAddress,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (address.hasCoordinates) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'موقعیت روی نقشه ثبت شده',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
              if (onSetDefault != null || onDelete != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onSetDefault != null && !address.isDefault)
                      TextButton(
                        onPressed: onSetDefault,
                        child: const Text('انتخاب به‌عنوان پیش‌فرض'),
                      ),
                    const Spacer(),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'حذف',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
