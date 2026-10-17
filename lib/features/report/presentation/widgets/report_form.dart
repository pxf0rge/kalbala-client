import 'package:flutter/material.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_reason_selector.dart';

/// Form fields for submitting a report.
class ReportForm extends StatelessWidget {
  const ReportForm({
    required this.target,
    required this.selectedReason,
    required this.descriptionController,
    required this.onReasonChanged,
    super.key,
  });

  final ReportTarget target;
  final ReportReason selectedReason;
  final TextEditingController descriptionController;
  final ValueChanged<ReportReason> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'گزارش ${target.type.label}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          target.label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ReportReasonSelector(
          selected: selectedReason,
          onChanged: onReasonChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'توضیحات (اختیاری)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
    );
  }
}
