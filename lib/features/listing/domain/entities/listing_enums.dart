/// Listing availability status.
enum ListingStatus {
  active,
  inactive,
  outOfStock;

  String get dbValue => switch (this) {
        ListingStatus.active => 'active',
        ListingStatus.inactive => 'inactive',
        ListingStatus.outOfStock => 'out_of_stock',
      };

  static ListingStatus fromDb(String value) {
    return switch (value) {
      'inactive' => ListingStatus.inactive,
      'out_of_stock' => ListingStatus.outOfStock,
      _ => ListingStatus.active,
    };
  }

  String get labelFa => switch (this) {
        ListingStatus.active => 'فعال',
        ListingStatus.inactive => 'غیرفعال',
        ListingStatus.outOfStock => 'ناموجود',
      };
}
