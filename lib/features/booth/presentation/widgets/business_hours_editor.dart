import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';

/// Compact editor for weekly business hours.
class BusinessHoursEditor extends StatelessWidget {
  const BusinessHoursEditor({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final BusinessHours value;
  final ValueChanged<BusinessHours> onChanged;

  static const _timeOptions = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ساعات کاری', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final key in BusinessHours.dayKeys) ...[
          _DayRow(
            dayKey: key,
            label: BusinessHours.dayLabelsFa[key] ?? key,
            day: value.days[key] ?? const DayHours(),
            timeOptions: _timeOptions,
            onChanged: (day) => onChanged(value.copyWithDay(key, day)),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dayKey,
    required this.label,
    required this.day,
    required this.timeOptions,
    required this.onChanged,
  });

  final String dayKey;
  final String label;
  final DayHours day;
  final List<String> timeOptions;
  final ValueChanged<DayHours> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Switch(
          value: !day.closed,
          onChanged: (open) => onChanged(day.copyWith(closed: !open)),
        ),
        if (!day.closed) ...[
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: timeOptions.contains(day.open) ? day.open : '09:00',
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'از',
              ),
              items: timeOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(day.copyWith(open: v));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: timeOptions.contains(day.close) ? day.close : '18:00',
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'تا',
              ),
              items: timeOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(day.copyWith(close: v));
              },
            ),
          ),
        ] else
          Expanded(
            child: Text(
              'تعطیل',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
