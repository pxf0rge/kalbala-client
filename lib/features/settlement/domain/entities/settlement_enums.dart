/// Settlement request lifecycle status.
enum SettlementStatus {
  requested,
  processing,
  completed,
  rejected;

  String get dbValue => switch (this) {
        SettlementStatus.requested => 'requested',
        SettlementStatus.processing => 'processing',
        SettlementStatus.completed => 'completed',
        SettlementStatus.rejected => 'rejected',
      };

  String get label => switch (this) {
        SettlementStatus.requested => 'در انتظار بررسی',
        SettlementStatus.processing => 'در حال پردازش',
        SettlementStatus.completed => 'تکمیل شده',
        SettlementStatus.rejected => 'رد شده',
      };

  static SettlementStatus fromDb(String value) => switch (value) {
        'requested' => SettlementStatus.requested,
        'processing' => SettlementStatus.processing,
        'completed' => SettlementStatus.completed,
        'rejected' => SettlementStatus.rejected,
        _ => SettlementStatus.requested,
      };
}
