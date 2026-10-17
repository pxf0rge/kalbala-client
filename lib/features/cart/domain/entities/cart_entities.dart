class CartItemEntity {
  const CartItemEntity({
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

  String? get primaryImage => productImages.isNotEmpty ? productImages.first : null;
  bool get hasStockIssue => quantity > availableStock;
}

class CartBoothGroupEntity {
  const CartBoothGroupEntity({
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    required this.items,
    this.boothLogoUrl,
  });

  final String boothId;
  final String boothName;
  final String boothSlug;
  final String? boothLogoUrl;
  final List<CartItemEntity> items;

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
}

class CartEntity {
  const CartEntity({
    required this.items,
    required this.boothGroups,
  });

  final List<CartItemEntity> items;
  final List<CartBoothGroupEntity> boothGroups;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
  bool get hasStockIssues => items.any((item) => item.hasStockIssue);
  bool get isEmpty => items.isEmpty;
}

List<CartBoothGroupEntity> groupCartItemsByBooth(List<CartItemEntity> items) {
  final groups = <String, List<CartItemEntity>>{};
  final boothMeta = <String, ({String name, String slug, String? logo})>{};

  for (final item in items) {
    groups.putIfAbsent(item.boothId, () => []).add(item);
    boothMeta[item.boothId] = (
      name: item.boothName,
      slug: item.boothSlug,
      logo: item.boothLogoUrl,
    );
  }

  return groups.entries.map((entry) {
    final meta = boothMeta[entry.key]!;
    return CartBoothGroupEntity(
      boothId: entry.key,
      boothName: meta.name,
      boothSlug: meta.slug,
      boothLogoUrl: meta.logo,
      items: entry.value,
    );
  }).toList();
}
