import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/payment/data/models/payment_models.dart';

class OrderModels {
  static OrderSummaryEntity summaryFromJson(Map<String, dynamic> json) {
    return OrderSummaryEntity(
      id: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.fromDb(json['status'] as String),
      totalAmount: _parseAmount(json['total_amount']),
      paymentMethod: CheckoutPaymentMethod.fromDb(json['payment_method'] as String),
      sellerOrderCount: (json['seller_order_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static OrderDetailEntity detailFromJson(Map<String, dynamic> json) {
    final sellerOrders = (json['seller_orders'] as List<dynamic>? ?? [])
        .map((row) => sellerOrderFromJson(row as Map<String, dynamic>))
        .toList();

    return OrderDetailEntity(
      id: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.fromDb(json['status'] as String),
      totalAmount: _parseAmount(json['total_amount']),
      shippingTotal: _parseAmount(json['shipping_total']),
      paymentMethod: CheckoutPaymentMethod.fromDb(json['payment_method'] as String),
      shippingAddress: Map<String, dynamic>.from(json['shipping_address'] as Map? ?? {}),
      sellerOrders: sellerOrders,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      payment: json['payment'] != null
          ? PaymentModels.orderPaymentFromJson(json['payment'] as Map<String, dynamic>)
          : null,
      buyerNote: json['buyer_note'] as String?,
    );
  }

  static SellerOrderEntity sellerOrderFromJson(Map<String, dynamic> json) {
    return SellerOrderEntity(
      id: json['seller_order_id'] as String,
      boothId: json['booth_id'] as String,
      boothName: json['booth_name'] as String,
      boothSlug: json['booth_slug'] as String,
      status: SellerOrderStatus.fromDb(json['status'] as String),
      subtotal: _parseAmount(json['subtotal']),
      shippingCost: _parseAmount(json['shipping_cost']),
      trackingNumber: json['tracking_number'] as String?,
      shippingProvider: json['shipping_provider'] as String?,
      shippingStatus: json['shipping_status'] as String?,
      boothPhone: json['booth_phone'] as String?,
      shipment: json['shipment'] != null
          ? shipmentFromJson(json['shipment'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((row) => itemFromJson(row as Map<String, dynamic>))
          .toList(),
      statusHistory: (json['status_history'] as List<dynamic>? ?? [])
          .map((row) => historyFromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }

  static SellerOrderSummaryEntity sellerSummaryFromJson(Map<String, dynamic> json) {
    return SellerOrderSummaryEntity(
      id: json['seller_order_id'] as String,
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      boothId: json['booth_id'] as String,
      boothName: json['booth_name'] as String,
      boothSlug: json['booth_slug'] as String,
      buyerName: json['buyer_name'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? '',
      status: SellerOrderStatus.fromDb(json['status'] as String),
      subtotal: _parseAmount(json['subtotal']),
      shippingCost: _parseAmount(json['shipping_cost']),
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentMethod: CheckoutPaymentMethod.fromDb(json['payment_method'] as String),
      trackingNumber: json['tracking_number'] as String?,
    );
  }

  static SellerOrderDetailEntity sellerDetailFromJson(Map<String, dynamic> json) {
    return SellerOrderDetailEntity(
      id: json['seller_order_id'] as String,
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      boothId: json['booth_id'] as String,
      boothName: json['booth_name'] as String,
      status: SellerOrderStatus.fromDb(json['status'] as String),
      subtotal: _parseAmount(json['subtotal']),
      shippingCost: _parseAmount(json['shipping_cost']),
      trackingNumber: json['tracking_number'] as String?,
      shippingProvider: json['shipping_provider'] as String?,
      shippingStatus: json['shipping_status'] as String?,
      buyerName: json['buyer_name'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? '',
      shippingAddress: Map<String, dynamic>.from(json['shipping_address'] as Map? ?? {}),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((row) => itemFromJson(row as Map<String, dynamic>))
          .toList(),
      statusHistory: (json['status_history'] as List<dynamic>? ?? [])
          .map((row) => historyFromJson(row as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentMethod: CheckoutPaymentMethod.fromDb(json['payment_method'] as String),
      commissionAmount: _parseAmount(json['commission_amount']),
      sellerPayout: _parseAmount(json['seller_payout']),
      commissionEnabled: json['commission_enabled'] as bool? ?? false,
      commissionRatePercent: _parseAmount(json['commission_rate_percent']),
      buyerNote: json['buyer_note'] as String?,
    );
  }

  static OrderItemEntity itemFromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['order_item_id'] as String,
      productName: json['product_name'] as String,
      listingId: json['listing_id'] as String?,
      variantName: json['variant_name'] as String?,
      sku: json['sku'] as String?,
      unitPrice: _parseAmount(json['unit_price']),
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: _parseAmount(json['total_price']),
      weightGrams: (json['weight_grams'] as num?)?.toInt() ?? 0,
      hasReview: json['has_review'] as bool? ?? false,
      canReview: json['can_review'] as bool? ?? false,
    );
  }

  static OrderStatusHistoryEntity historyFromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryEntity(
      id: json['id'] as String,
      fromStatus: json['from_status'] != null
          ? SellerOrderStatus.fromDb(json['from_status'] as String)
          : null,
      toStatus: SellerOrderStatus.fromDb(json['to_status'] as String),
      trackingNumber: json['tracking_number'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static ShipmentEntity shipmentFromJson(Map<String, dynamic> json) {
    return ShipmentEntity(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      provider: json['provider'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at'] as String) : null,
      deliveredAt:
          json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
