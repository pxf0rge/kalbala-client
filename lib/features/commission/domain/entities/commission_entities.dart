/// Commission calculation result for seller payout display.
class CommissionBreakdown {
  const CommissionBreakdown({
    required this.subtotal,
    required this.commissionAmount,
    required this.sellerPayout,
    required this.shippingCost,
    required this.commissionEnabled,
    this.commissionRatePercent = 0,
  });

  final double subtotal;
  final double commissionAmount;
  final double sellerPayout;
  final double shippingCost;
  final bool commissionEnabled;
  final double commissionRatePercent;

  double get netEarnings => sellerPayout + shippingCost;

  String get commissionLabel {
    if (!commissionEnabled) return 'کارمزد پلتفرم (دوره رایگان)';
    if (commissionRatePercent <= 0) return 'کارمزد پلتفرم';
    return 'کارمزد پلتفرم (${commissionRatePercent.toStringAsFixed(0)}٪)';
  }

  static CommissionBreakdown fromSellerOrder({
    required double subtotal,
    required double commissionAmount,
    required double sellerPayout,
    required double shippingCost,
    required bool commissionEnabled,
    double commissionRatePercent = 0,
  }) {
    return CommissionBreakdown(
      subtotal: subtotal,
      commissionAmount: commissionAmount,
      sellerPayout: sellerPayout,
      shippingCost: shippingCost,
      commissionEnabled: commissionEnabled,
      commissionRatePercent: commissionRatePercent,
    );
  }
}

/// Pure calculation mirror of server-side `calculate_commission` for tests.
({double commissionAmount, double sellerPayout, double ratePercent}) calculateCommission({
  required bool commissionEnabled,
  required double amount,
  double defaultRatePercent = 0,
  double? boothRatePercent,
}) {
  final normalizedAmount = amount < 0 ? 0.0 : amount.toDouble();

  if (!commissionEnabled) {
    return (commissionAmount: 0, sellerPayout: normalizedAmount, ratePercent: 0);
  }

  final rate = boothRatePercent ?? defaultRatePercent;
  final commission = double.parse((normalizedAmount * rate / 100).toStringAsFixed(2));
  final payout = normalizedAmount - commission;

  return (
    commissionAmount: commission,
    sellerPayout: payout < 0 ? 0 : payout,
    ratePercent: rate,
  );
}
