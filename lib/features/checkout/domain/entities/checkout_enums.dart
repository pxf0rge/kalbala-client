/// Payment method for checkout.
enum CheckoutPaymentMethod {
  online,
  cod;

  String get dbValue => switch (this) {
        CheckoutPaymentMethod.online => 'online',
        CheckoutPaymentMethod.cod => 'cod',
      };

  String get label => switch (this) {
        CheckoutPaymentMethod.online => 'پرداخت آنلاین',
        CheckoutPaymentMethod.cod => 'پرداخت در محل',
      };

  static CheckoutPaymentMethod fromDb(String value) => switch (value) {
        'online' => CheckoutPaymentMethod.online,
        'cod' => CheckoutPaymentMethod.cod,
        _ => CheckoutPaymentMethod.online,
      };
}
