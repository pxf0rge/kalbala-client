/// Payment gateway options for online checkout.
enum PaymentGateway {
  hesabpay,
  automapay;

  String get dbValue => switch (this) {
        PaymentGateway.hesabpay => 'hesabpay',
        PaymentGateway.automapay => 'automapay',
      };

  String get label => switch (this) {
        PaymentGateway.hesabpay => 'حساب‌پی',
        PaymentGateway.automapay => 'اتوماپی',
      };

  static PaymentGateway fromDb(String value) => switch (value) {
        'hesabpay' => PaymentGateway.hesabpay,
        'automapay' => PaymentGateway.automapay,
        _ => PaymentGateway.hesabpay,
      };
}

/// Payment lifecycle status from backend.
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded;

  String get dbValue => switch (this) {
        PaymentStatus.pending => 'pending',
        PaymentStatus.processing => 'processing',
        PaymentStatus.completed => 'completed',
        PaymentStatus.failed => 'failed',
        PaymentStatus.refunded => 'refunded',
      };

  String get label => switch (this) {
        PaymentStatus.pending => 'در انتظار پرداخت',
        PaymentStatus.processing => 'در حال پردازش',
        PaymentStatus.completed => 'پرداخت موفق',
        PaymentStatus.failed => 'پرداخت ناموفق',
        PaymentStatus.refunded => 'بازپرداخت شده',
      };

  bool get isTerminal => this == PaymentStatus.completed || this == PaymentStatus.refunded;

  static PaymentStatus fromDb(String value) => switch (value) {
        'pending' => PaymentStatus.pending,
        'processing' => PaymentStatus.processing,
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}
