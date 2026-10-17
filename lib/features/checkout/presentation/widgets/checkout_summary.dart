import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';

/// Checkout totals summary bar.
class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({
    required this.summary,
    required this.onPlaceOrder,
    this.isLoading = false,
    this.canSubmit = true,
    super.key,
  });

  final CheckoutSummaryEntity summary;
  final VoidCallback? onPlaceOrder;
  final bool isLoading;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Material(
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('جمع کالا'),
                  Text('${priceFormat.format(summary.subtotal)} ${AppConstants.currencySymbol}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('هزینه ارسال'),
                  Text('${priceFormat.format(summary.shippingTotal)} ${AppConstants.currencySymbol}'),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${priceFormat.format(summary.total)} ${AppConstants.currencySymbol}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                    ),
                  ),
                  FilledButton(
                    onPressed: canSubmit && !isLoading ? onPlaceOrder : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ثبت سفارش'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
