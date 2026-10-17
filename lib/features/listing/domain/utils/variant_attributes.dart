import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';

/// Normalized color/size/model keys from `listing_variants.attributes`.
class VariantAttributes {
  const VariantAttributes({this.color, this.size, this.model});

  final String? color;
  final String? size;
  final String? model;

  bool get hasAny => color != null || size != null || model != null;

  static const _colorKeys = ['color', 'colour', 'رنگ'];
  static const _sizeKeys = ['size', 'سایز', 'سايز'];
  static const _modelKeys = ['model', 'مدل'];

  /// Preferred write keys for seller forms / DB (PDP accepts فارسی aliases too).
  Map<String, String> toMap() {
    final map = <String, String>{};
    final c = color?.trim();
    final s = size?.trim();
    final m = model?.trim();
    if (c != null && c.isNotEmpty) map['color'] = c;
    if (s != null && s.isNotEmpty) map['size'] = s;
    if (m != null && m.isNotEmpty) map['model'] = m;
    return map;
  }

  /// Display name when seller leaves the name blank.
  String suggestedName({String fallback = 'تنوع'}) {
    final parts = <String>[
      if (color != null && color!.trim().isNotEmpty) color!.trim(),
      if (size != null && size!.trim().isNotEmpty) size!.trim(),
      if (model != null && model!.trim().isNotEmpty) model!.trim(),
    ];
    if (parts.isEmpty) return fallback;
    return parts.join(' / ');
  }

  static VariantAttributes parse(Map<String, String> raw) {
    String? pick(List<String> keys) {
      for (final entry in raw.entries) {
        final key = entry.key.trim().toLowerCase();
        if (keys.contains(key) || keys.contains(entry.key.trim())) {
          final value = entry.value.trim();
          if (value.isNotEmpty) return value;
        }
      }
      return null;
    }

    return VariantAttributes(
      color: pick(_colorKeys),
      size: pick(_sizeKeys),
      model: pick(_modelKeys),
    );
  }

  static List<String> uniqueValues(
    List<ListingVariantEntity> variants,
    String? Function(VariantAttributes attrs) selector,
  ) {
    final seen = <String>{};
    final result = <String>[];
    for (final variant in variants) {
      final value = selector(parse(variant.attributes));
      if (value == null || value.isEmpty || seen.contains(value)) continue;
      seen.add(value);
      result.add(value);
    }
    return result;
  }

  /// Human-readable rows for the specs section (known keys first).
  static List<MapEntry<String, String>> displayRows(Map<String, String> raw) {
    final parsed = parse(raw);
    final rows = <MapEntry<String, String>>[];
    if (parsed.color != null) rows.add(MapEntry('رنگ', parsed.color!));
    if (parsed.size != null) rows.add(MapEntry('سایز', parsed.size!));
    if (parsed.model != null) rows.add(MapEntry('مدل', parsed.model!));

    final known = {..._colorKeys, ..._sizeKeys, ..._modelKeys};
    for (final entry in raw.entries) {
      final keyLower = entry.key.trim().toLowerCase();
      if (known.contains(keyLower) || known.contains(entry.key.trim())) continue;
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      rows.add(MapEntry(entry.key, value));
    }
    return rows;
  }
}
