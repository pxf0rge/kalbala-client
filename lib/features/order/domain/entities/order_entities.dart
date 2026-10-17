import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';

class OrderSummaryEntity {
  const OrderSummaryEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.sellerOrderCount,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final double totalAmount;
  final CheckoutPaymentMethod paymentMethod;
  final int sellerOrderCount;
  final DateTime createdAt;
}

class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.listingId,
    this.variantName,
    this.sku,
    this.weightGrams = 0,
    this.hasReview = false,
    this.canReview = false,
  });

  final String id;
  final String productName;
  final String? listingId;
  final String? variantName;
  final String? sku;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final int weightGrams;
  final bool hasReview;
  final bool canReview;
}

class ShipmentEntity {
  const ShipmentEntity({
    required this.id,
    required this.status,
    this.provider,
    this.trackingNumber,
    this.shippedAt,
    this.deliveredAt,
  });

  final String id;
  final String status;
  final String? provider;
  final String? trackingNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
}

class OrderStatusHistoryEntity {
  const OrderStatusHistoryEntity({
    required this.id,
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.trackingNumber,
    this.note,
  });

  final String id;
  final SellerOrderStatus? fromStatus;
  final SellerOrderStatus toStatus;
  final String? trackingNumber;
  final String? note;
  final DateTime createdAt;
}

class SellerOrderEntity {
  const SellerOrderEntity({
    required this.id,
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.items,
    required this.statusHistory,
    this.trackingNumber,
    this.shippingProvider,
    this.shippingStatus,
    this.shipment,
    this.boothPhone,
  });

  final String id;
  final String boothId;
  final String boothName;
  final String boothSlug;
  final SellerOrderStatus status;
  final double subtotal;
  final double shippingCost;
  final String? trackingNumber;
  final String? shippingProvider;
  final String? shippingStatus;
  final ShipmentEntity? shipment;
  final String? boothPhone;
  final List<OrderItemEntity> items;
  final List<OrderStatusHistoryEntity> statusHistory;

  double get total => subtotal + shippingCost;
}

class OrderDetailEntity {
  const OrderDetailEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.shippingTotal,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.sellerOrders,
    required this.createdAt,
    this.expiresAt,
    this.payment,
    this.buyerNote,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final double totalAmount;
  final double shippingTotal;
  final CheckoutPaymentMethod paymentMethod;
  final Map<String, dynamic> shippingAddress;
  final List<SellerOrderEntity> sellerOrders;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final OrderPaymentSummaryEntity? payment;
  final String? buyerNote;

  bool get canPayOnline =>
      paymentMethod == CheckoutPaymentMethod.online &&
      (status == OrderStatus.pendingPayment || status == OrderStatus.paymentFailed);
}

class SellerOrderSummaryEntity {
  const SellerOrderSummaryEntity({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    required this.buyerName,
    required this.buyerPhone,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.itemCount,
    required this.createdAt,
    required this.paymentMethod,
    this.trackingNumber,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final String boothId;
  final String boothName;
  final String boothSlug;
  final String buyerName;
  final String buyerPhone;
  final SellerOrderStatus status;
  final double subtotal;
  final double shippingCost;
  final int itemCount;
  final DateTime createdAt;
  final CheckoutPaymentMethod paymentMethod;
  final String? trackingNumber;

  double get total => subtotal + shippingCost;
}

class SellerOrderDetailEntity {
  const SellerOrderDetailEntity({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.boothId,
    required this.boothName,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.buyerName,
    required this.buyerPhone,
    required this.shippingAddress,
    required this.items,
    required this.statusHistory,
    required this.createdAt,
    required this.paymentMethod,
    this.trackingNumber,
    this.shippingProvider,
    this.shippingStatus,
    this.commissionAmount = 0,
    this.sellerPayout = 0,
    this.commissionEnabled = false,
    this.commissionRatePercent = 0,
    this.buyerNote,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final String boothId;
  final String boothName;
  final SellerOrderStatus status;
  final double subtotal;
  final double shippingCost;
  final String? trackingNumber;
  final String? shippingProvider;
  final String? shippingStatus;
  final String buyerName;
  final String buyerPhone;
  final Map<String, dynamic> shippingAddress;
  final List<OrderItemEntity> items;
  final List<OrderStatusHistoryEntity> statusHistory;
  final DateTime createdAt;
  final CheckoutPaymentMethod paymentMethod;
  final double commissionAmount;
  final double sellerPayout;
  final bool commissionEnabled;
  final double commissionRatePercent;
  final String? buyerNote;

  double get total => subtotal + shippingCost;

  double get netEarnings => sellerPayout + shippingCost;
}
