import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';

class ShippingPreviewModel {
  static ShippingPreviewEntity fromJson(Map<String, dynamic> json) {
    final boothList = json['booth_shipping'] as List<dynamic>? ?? [];
    return ShippingPreviewEntity(
      city: json['city'] as String? ?? '',
      boothShipping: boothList
          .map((row) => BoothShippingModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      shippingTotal: _parseAmount(json['shipping_total']),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BoothShippingModel {
  static BoothShippingEntity fromJson(Map<String, dynamic> json) {
    return BoothShippingEntity(
      boothId: json['booth_id'] as String,
      weightGrams: (json['weight_grams'] as num?)?.toInt() ?? 0,
      shippingCost: ShippingPreviewModel._parseAmount(json['shipping_cost']),
    );
  }
}
