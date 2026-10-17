import 'package:flutter/material.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';

/// Selector for permanent vs rental booth ownership.
class OwnershipTypeSelector extends StatelessWidget {
  const OwnershipTypeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final OwnershipType value;
  final ValueChanged<OwnershipType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OwnershipType>(
      segments: OwnershipType.values
          .map((type) => ButtonSegment(value: type, label: Text(type.labelFa)))
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
