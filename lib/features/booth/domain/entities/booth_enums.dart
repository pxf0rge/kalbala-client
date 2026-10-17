/// Booth ownership model (permanent purchase or rental).
enum OwnershipType {
  permanent,
  rental;

  String get dbValue => name;

  static OwnershipType fromDb(String value) {
    return OwnershipType.values.firstWhere((e) => e.name == value);
  }

  String get labelFa => switch (this) {
        OwnershipType.permanent => 'خرید دائمی',
        OwnershipType.rental => 'اجاره‌ای',
      };
}

/// Approval workflow status.
enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get dbValue => name;

  static ApprovalStatus fromDb(String value) {
    return ApprovalStatus.values.firstWhere((e) => e.name == value);
  }

  String get labelFa => switch (this) {
        ApprovalStatus.pending => 'در انتظار بررسی',
        ApprovalStatus.approved => 'تأیید شده',
        ApprovalStatus.rejected => 'رد شده',
      };
}
