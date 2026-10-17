class ShippingPreviewEntity {
  const ShippingPreviewEntity({
    required this.city,
    required this.boothShipping,
    required this.shippingTotal,
  });

  final String city;
  final List<BoothShippingEntity> boothShipping;
  final double shippingTotal;
}

class BoothShippingEntity {
  const BoothShippingEntity({
    required this.boothId,
    required this.weightGrams,
    required this.shippingCost,
  });

  final String boothId;
  final int weightGrams;
  final double shippingCost;
}
