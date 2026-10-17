import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';

abstract final class SellerDashboardModels {
  static SellerDashboardStatsEntity statsFromJson(Map<String, dynamic> json) {
    final topProductsRaw = json['top_products'];
    final topProducts = <TopProductEntity>[];

    if (topProductsRaw is List) {
      for (final item in topProductsRaw) {
        if (item is Map<String, dynamic>) {
          topProducts.add(topProductFromJson(item));
        } else if (item is Map) {
          topProducts.add(topProductFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SellerDashboardStatsEntity(
      orderCount: _parseInt(json['order_count']),
      totalSales: _parseAmount(json['total_sales']),
      availableBalance: _parseAmount(json['available_balance']),
      productCount: _parseInt(json['product_count']),
      topProducts: topProducts,
      boothViews: _parseInt(json['booth_views']),
      followerCount: _parseInt(json['follower_count']),
    );
  }

  static TopProductEntity topProductFromJson(Map<String, dynamic> json) {
    return TopProductEntity(
      productName: json['product_name'] as String? ?? '',
      listingId: json['listing_id'] as String? ?? '',
      totalQuantity: _parseInt(json['total_quantity']),
      totalSales: _parseAmount(json['total_sales']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
