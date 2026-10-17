import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';

/// Order preview grouped by booth at checkout.
class BoothOrderGroup extends StatelessWidget {
  const BoothOrderGroup({required this.group, super.key});

  final BoothCheckoutGroupEntity group;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (group.boothLogoUrl != null)
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(group.boothLogoUrl!),
                    radius: 16,
                  )
                else
                  const CircleAvatar(radius: 16, child: Icon(Icons.storefront, size: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(group.boothName, style: Theme.of(context).textTheme.titleSmall)),
              ],
            ),
            const Divider(height: 16),
            ...group.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName}${item.variantName != null ? ' (${item.variantName})' : ''}',
                      ),
                    ),
                    Text('${item.quantity} × ${priceFormat.format(item.unitPrice)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('جمع کالا: ${priceFormat.format(group.subtotal)} ${AppConstants.currencySymbol}'),
            Text('هزینه ارسال: ${priceFormat.format(group.shippingCost)} ${AppConstants.currencySymbol}'),
            Text(
              'جمع فروشگاه: ${priceFormat.format(group.total)} ${AppConstants.currencySymbol}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
