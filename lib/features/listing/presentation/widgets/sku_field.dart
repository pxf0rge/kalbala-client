import 'package:flutter/material.dart';

/// SKU input with optional helper text.
class SkuField extends StatelessWidget {
  const SkuField({
    required this.controller,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'کد SKU (اختیاری)',
        hintText: 'مثال: PRD-001',
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
    );
  }
}
