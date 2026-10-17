import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';

class PlaceOrderResultModel {
  const PlaceOrderResultModel({
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

  factory PlaceOrderResultModel.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResultModel(
      orderId: json['order_id'] as String,
      orderNumber: json['order_number'] as String,
      paymentMethod: CheckoutPaymentMethod.fromDb(json['payment_method'] as String),
      totalAmount: _parseAmount(json['total_amount']),
      shippingTotal: _parseAmount(json['shipping_total']),
      status: json['status'] as String,
    );
  }

  PlaceOrderResultEntity toEntity() {
    return PlaceOrderResultEntity(
      orderId: orderId,
      orderNumber: orderNumber,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      shippingTotal: shippingTotal,
      status: status,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
