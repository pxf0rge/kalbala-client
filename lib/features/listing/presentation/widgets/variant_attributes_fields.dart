import 'package:flutter/material.dart';
import 'package:rahmani_project/features/listing/domain/utils/variant_attributes.dart';

/// Color / size / model inputs aligned with PDP `VariantAttributes` contract.
class VariantAttributesFields extends StatelessWidget {
  const VariantAttributesFields({
    required this.colorController,
    required this.sizeController,
    required this.modelController,
    super.key,
  });

  final TextEditingController colorController;
  final TextEditingController sizeController;
  final TextEditingController modelController;

  static Map<String, String> collect({
    required TextEditingController colorController,
    required TextEditingController sizeController,
    required TextEditingController modelController,
  }) {
    return VariantAttributes(
      color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
      size: sizeController.text.trim().isEmpty ? null : sizeController.text.trim(),
      model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
    ).toMap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: colorController,
          decoration: const InputDecoration(
            labelText: 'رنگ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: sizeController,
          decoration: const InputDecoration(
            labelText: 'سایز',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: modelController,
          decoration: const InputDecoration(
            labelText: 'مدل',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
