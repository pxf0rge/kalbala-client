import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';

/// Price and stock inputs for listings and variants.
class PriceStockForm extends StatelessWidget {
  const PriceStockForm({
    required this.priceController,
    required this.stockController,
    this.comparePriceController,
    this.priceValidator,
    this.stockValidator,
    this.stockEnabled = true,
    this.stockHelperText,
    super.key,
  });

  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController? comparePriceController;
  final String? Function(String?)? priceValidator;
  final String? Function(String?)? stockValidator;
  final bool stockEnabled;
  final String? stockHelperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: 'قیمت (${AppConstants.currencySymbol})',
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: priceValidator ??
              (value) {
                if (value == null || value.trim().isEmpty) return 'قیمت الزامی است';
                final price = double.tryParse(value);
                if (price == null || price < 0) return 'قیمت نامعتبر است';
                return null;
              },
        ),
        if (comparePriceController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: comparePriceController,
            decoration: const InputDecoration(
              labelText: 'قیمت قبلی / تخفیف‌خورده (${AppConstants.currencySymbol})',
              hintText: 'اختیاری — برای نمایش تخفیف',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final price = double.tryParse(value);
              if (price == null || price < 0) return 'قیمت نامعتبر است';
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: stockController,
          enabled: stockEnabled,
          decoration: InputDecoration(
            labelText: 'موجودی',
            border: const OutlineInputBorder(),
            helperText: stockHelperText,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: stockEnabled
              ? (stockValidator ??
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'موجودی الزامی است';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) return 'موجودی نامعتبر است';
                    return null;
                  })
              : null,
        ),
      ],
    );
  }
}
