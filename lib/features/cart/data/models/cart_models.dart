import 'package:rahmani_project/features/cart/domain/entities/cart_entities.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.listingId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.availableStock,
    required this.productName,
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    this.variantId,
    this.variantName,
    this.productImages = const [],
    this.boothLogoUrl,
    this.weightGrams = 0,
  });

  final String id;
  final String listingId;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int availableStock;
  final String productName;
  final List<String> productImages;
  final String boothId;
  final String boothName;
  final String boothSlug;
  final String? boothLogoUrl;
  final int weightGrams;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final images = json['product_images'];
    return CartItemModel(
      id: json['cart_item_id'] as String,
      listingId: json['listing_id'] as String,
      variantId: json['variant_id'] as String?,
      variantName: json['variant_name'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: _parsePrice(json['unit_price']),
      lineTotal: _parsePrice(json['line_total']),
      availableStock: json['available_stock'] as int? ?? 0,
      productName: json['product_name'] as String,
      productImages: images is List ? images.map((e) => e.toString()).toList() : [],
      boothId: json['booth_id'] as String,
      boothName: json['booth_name'] as String,
      boothSlug: json['booth_slug'] as String,
      boothLogoUrl: json['booth_logo_url'] as String?,
      weightGrams: json['weight_grams'] as int? ?? 0,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      listingId: listingId,
      variantId: variantId,
      variantName: variantName,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      availableStock: availableStock,
      productName: productName,
      productImages: productImages,
      boothId: boothId,
      boothName: boothName,
      boothSlug: boothSlug,
      boothLogoUrl: boothLogoUrl,
      weightGrams: weightGrams,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
