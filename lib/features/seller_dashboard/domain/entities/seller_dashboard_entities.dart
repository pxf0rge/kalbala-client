class TopProductEntity {
  const TopProductEntity({
    required this.productName,
    required this.listingId,
    required this.totalQuantity,
    required this.totalSales,
  });

  final String productName;
  final String listingId;
  final int totalQuantity;
  final double totalSales;
}

class SellerDashboardStatsEntity {
  const SellerDashboardStatsEntity({
    required this.orderCount,
    required this.totalSales,
    required this.availableBalance,
    required this.productCount,
    required this.topProducts,
    required this.boothViews,
    required this.followerCount,
  });

  final int orderCount;
  final double totalSales;
  final double availableBalance;
  final int productCount;
  final List<TopProductEntity> topProducts;
  final int boothViews;
  final int followerCount;

  bool get hasTopProducts => topProducts.isNotEmpty;
}
