import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';

class BoothCheckoutGroupEntity {
  const BoothCheckoutGroupEntity({
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    this.boothLogoUrl,
    this.weightGrams = 0,
  });

  final String boothId;
  final String boothName;
  final String boothSlug;
  final String? boothLogoUrl;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final int weightGrams;

  double get total => subtotal + shippingCost;
}

class CheckoutSummaryEntity {
  const CheckoutSummaryEntity({
    required this.boothGroups,
    required this.subtotal,
    required this.shippingTotal,
    required this.total,
    required this.itemCount,
    this.hasStockIssues = false,
    this.city,
  });

  final List<BoothCheckoutGroupEntity> boothGroups;
  final double subtotal;
  final double shippingTotal;
  final double total;
  final int itemCount;
  final bool hasStockIssues;
  final String? city;

  bool get isEmpty => boothGroups.isEmpty;
}

class PlaceOrderResultEntity {
  const PlaceOrderResultEntity({
    required this.orderId,
    required this.orderNumber,
    required this.paymentMethod,
    required this.totalAmount,
    required this.status,
    this.shippingTotal = 0,
  });

  final String orderId;
  final String orderNumber;
  final CheckoutPaymentMethod paymentMethod;
  final double totalAmount;
  final double shippingTotal;
  final String status;

  bool get requiresOnlinePayment =>
      paymentMethod == CheckoutPaymentMethod.online && status == 'pending_payment';
}

CheckoutSummaryEntity buildCheckoutSummary({
  required List<CartItemEntity> items,
  ShippingPreviewEntity? shippingPreview,
}) {
  final shippingByBooth = {
    for (final entry in shippingPreview?.boothShipping ?? <BoothShippingEntity>[])
      entry.boothId: entry,
  };

  final cartGroups = groupCartItemsByBooth(items);
  final boothGroups = cartGroups.map((group) {
    final shipping = shippingByBooth[group.boothId];
    final weightGrams = shipping?.weightGrams ??
        group.items.fold<int>(0, (sum, item) => sum + item.weightGrams * item.quantity);
    return BoothCheckoutGroupEntity(
      boothId: group.boothId,
      boothName: group.boothName,
      boothSlug: group.boothSlug,
      boothLogoUrl: group.boothLogoUrl,
      items: group.items,
      subtotal: group.subtotal,
      shippingCost: shipping?.shippingCost ?? 0,
      weightGrams: weightGrams,
    );
  }).toList();

  final subtotal = boothGroups.fold(0.0, (sum, g) => sum + g.subtotal);
  final shippingTotal = shippingPreview?.shippingTotal ??
      boothGroups.fold<double>(0.0, (sum, g) => sum + g.shippingCost);

  return CheckoutSummaryEntity(
    boothGroups: boothGroups,
    subtotal: subtotal,
    shippingTotal: shippingTotal,
    total: subtotal + shippingTotal,
    itemCount: items.fold(0, (sum, item) => sum + item.quantity),
    hasStockIssues: items.any((item) => item.hasStockIssue),
    city: shippingPreview?.city,
  );
}
