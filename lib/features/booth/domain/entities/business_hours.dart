/// Structured business hours for booths (keys: sat..fri).
class BusinessHours {
  const BusinessHours({this.days = const {}});

  final Map<String, DayHours> days;

  static const dayKeys = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];

  static const dayLabelsFa = {
    'sat': 'شنبه',
    'sun': 'یکشنبه',
    'mon': 'دوشنبه',
    'tue': 'سه‌شنبه',
    'wed': 'چهارشنبه',
    'thu': 'پنجشنبه',
    'fri': 'جمعه',
  };

  static BusinessHours defaults() {
    return BusinessHours(
      days: {
        for (final key in dayKeys)
          key: key == 'fri'
              ? const DayHours(open: '09:00', close: '18:00', closed: true)
              : const DayHours(open: '09:00', close: '18:00'),
      },
    );
  }

  factory BusinessHours.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return BusinessHours.defaults();
    final days = <String, DayHours>{};
    for (final key in dayKeys) {
      final raw = json[key];
      if (raw is Map) {
        days[key] = DayHours.fromJson(Map<String, dynamic>.from(raw));
      } else {
        days[key] = key == 'fri'
            ? const DayHours(open: '09:00', close: '18:00', closed: true)
            : const DayHours(open: '09:00', close: '18:00');
      }
    }
    return BusinessHours(days: days);
  }

  Map<String, dynamic> toJson() => {
        for (final entry in days.entries) entry.key: entry.value.toJson(),
      };

  BusinessHours copyWithDay(String key, DayHours day) {
    return BusinessHours(days: {...days, key: day});
  }
}

class DayHours {
  const DayHours({
    this.open = '09:00',
    this.close = '18:00',
    this.closed = false,
  });

  final String open;
  final String close;
  final bool closed;

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      open: json['open']?.toString() ?? '09:00',
      close: json['close']?.toString() ?? '18:00',
      closed: json['closed'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'open': open,
        'close': close,
        'closed': closed,
      };

  DayHours copyWith({String? open, String? close, bool? closed}) {
    return DayHours(
      open: open ?? this.open,
      close: close ?? this.close,
      closed: closed ?? this.closed,
    );
  }
}
