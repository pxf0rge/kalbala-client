/// Report target types (matches DB enum).
enum ReportTargetType {
  product,
  booth,
  user,
  review;

  String get dbValue => name;

  String get label => switch (this) {
        ReportTargetType.product => 'محصول',
        ReportTargetType.booth => 'فروشگاه',
        ReportTargetType.user => 'کاربر',
        ReportTargetType.review => 'نظر',
      };

  static ReportTargetType fromDb(String value) => switch (value) {
        'product' => ReportTargetType.product,
        'booth' => ReportTargetType.booth,
        'user' => ReportTargetType.user,
        'review' => ReportTargetType.review,
        _ => ReportTargetType.product,
      };
}

/// Report lifecycle status.
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed;

  String get dbValue => name;

  String get label => switch (this) {
        ReportStatus.pending => 'در انتظار بررسی',
        ReportStatus.reviewed => 'بررسی شده',
        ReportStatus.resolved => 'رسیدگی شده',
        ReportStatus.dismissed => 'رد شده',
      };

  static ReportStatus fromDb(String value) => switch (value) {
        'pending' => ReportStatus.pending,
        'reviewed' => ReportStatus.reviewed,
        'resolved' => ReportStatus.resolved,
        'dismissed' => ReportStatus.dismissed,
        _ => ReportStatus.pending,
      };
}

/// Predefined report reasons.
enum ReportReason {
  spam,
  inappropriate,
  fake,
  other;

  String get dbValue => name;

  String get label => switch (this) {
        ReportReason.spam => 'تبلیغات',
        ReportReason.inappropriate => 'محتوای نامناسب',
        ReportReason.fake => 'جعلی / گمراه‌کننده',
        ReportReason.other => 'سایر',
      };
}

class ReportTarget {
  const ReportTarget({
    required this.type,
    required this.targetId,
    required this.label,
  });

  final ReportTargetType type;
  final String targetId;
  final String label;
}

class ReportEntity {
  const ReportEntity({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.description,
    this.resolvedAt,
  });

  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  String get reasonLabel {
    for (final item in ReportReason.values) {
      if (item.dbValue == reason) return item.label;
    }
    return reason;
  }
}

class SubmitReportInput {
  const SubmitReportInput({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
  });

  final ReportTargetType targetType;
  final String targetId;
  final ReportReason reason;
  final String? description;
}

/// Validates report submission input.
String? validateReportInput(SubmitReportInput input) {
  if (input.targetId.isEmpty) return 'هدف گزارش نامعتبر است.';
  if (input.description != null && input.description!.trim().length > 1000) {
    return 'توضیحات حداکثر ۱۰۰۰ کاراکتر می‌تواند باشد.';
  }
  return null;
}

String reportReasonLabel(String reason) {
  for (final item in ReportReason.values) {
    if (item.dbValue == reason) return item.label;
  }
  return reason;
}
