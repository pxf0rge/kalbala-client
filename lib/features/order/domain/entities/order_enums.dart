/// Parent order status.
enum OrderStatus {
  pendingPayment,
  paymentFailed,
  confirmed,
  cancelled,
  completed;

  String get dbValue => switch (this) {
        OrderStatus.pendingPayment => 'pending_payment',
        OrderStatus.paymentFailed => 'payment_failed',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.cancelled => 'cancelled',
        OrderStatus.completed => 'completed',
      };

  String get labelFa => switch (this) {
        OrderStatus.pendingPayment => 'در انتظار پرداخت',
        OrderStatus.paymentFailed => 'پرداخت ناموفق',
        OrderStatus.confirmed => 'تأیید شده',
        OrderStatus.cancelled => 'لغو شده',
        OrderStatus.completed => 'تکمیل شده',
      };

  static OrderStatus fromDb(String value) => switch (value) {
        'pending_payment' => OrderStatus.pendingPayment,
        'payment_failed' => OrderStatus.paymentFailed,
        'confirmed' => OrderStatus.confirmed,
        'cancelled' => OrderStatus.cancelled,
        'completed' => OrderStatus.completed,
        _ => OrderStatus.confirmed,
      };
}

/// Per-booth seller order status.
enum SellerOrderStatus {
  pending,
  reviewing,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  String get dbValue => name;

  String get labelFa => switch (this) {
        SellerOrderStatus.pending => 'در انتظار',
        SellerOrderStatus.reviewing => 'در حال بررسی',
        SellerOrderStatus.confirmed => 'تأیید شده',
        SellerOrderStatus.processing => 'در حال پردازش',
        SellerOrderStatus.shipped => 'ارسال شده',
        SellerOrderStatus.delivered => 'تحویل شده',
        SellerOrderStatus.cancelled => 'لغو شده',
        SellerOrderStatus.refunded => 'مرجوع شده',
      };

  static SellerOrderStatus fromDb(String value) => switch (value) {
        'pending' => SellerOrderStatus.pending,
        'reviewing' => SellerOrderStatus.reviewing,
        'confirmed' => SellerOrderStatus.confirmed,
        'processing' => SellerOrderStatus.processing,
        'shipped' => SellerOrderStatus.shipped,
        'delivered' => SellerOrderStatus.delivered,
        'cancelled' => SellerOrderStatus.cancelled,
        'refunded' => SellerOrderStatus.refunded,
        _ => SellerOrderStatus.pending,
      };

  /// Default forward step for the seller action button.
  SellerOrderStatus? get nextStatus => switch (this) {
        SellerOrderStatus.pending => SellerOrderStatus.reviewing,
        SellerOrderStatus.reviewing => SellerOrderStatus.confirmed,
        SellerOrderStatus.confirmed => SellerOrderStatus.processing,
        SellerOrderStatus.processing => SellerOrderStatus.shipped,
        SellerOrderStatus.shipped => SellerOrderStatus.delivered,
        _ => null,
      };
}
