import 'package:flutter/material.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';

/// Radio list for predefined report reasons.
class ReportReasonSelector extends StatelessWidget {
  const ReportReasonSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ReportReason selected;
  final ValueChanged<ReportReason> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('دلیل گزارش', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...ReportReason.values.map(
          (reason) => RadioListTile<ReportReason>(
            value: reason,
            groupValue: selected,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            title: Text(reason.label),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
