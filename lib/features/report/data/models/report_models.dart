import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';

abstract final class ReportModels {
  static ReportEntity fromJson(Map<String, dynamic> json) {
    return ReportEntity(
      id: json['id'] as String,
      targetType: ReportTargetType.fromDb(json['target_type'] as String),
      targetId: json['target_id'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: ReportStatus.fromDb(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }
}
