/// Analytics event types matching `analytics_event_type` enum.
enum AnalyticsEventType {
  productView,
  addToCart,
  purchase,
  boothView;

  String get dbValue => switch (this) {
        AnalyticsEventType.productView => 'product_view',
        AnalyticsEventType.addToCart => 'add_to_cart',
        AnalyticsEventType.purchase => 'purchase',
        AnalyticsEventType.boothView => 'booth_view',
      };
}
