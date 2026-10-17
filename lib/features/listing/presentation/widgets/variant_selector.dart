import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/utils/variant_attributes.dart';

/// Variant picker: structured color/size/model when available, else name chips.
class VariantSelector extends StatefulWidget {
  const VariantSelector({
    required this.variants,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<ListingVariantEntity> variants;
  final String? selectedId;
  final ValueChanged<ListingVariantEntity> onSelected;

  @override
  State<VariantSelector> createState() => _VariantSelectorState();
}

class _VariantSelectorState extends State<VariantSelector> {
  String? _color;
  String? _size;
  String? _model;

  @override
  void initState() {
    super.initState();
    _syncFromSelected();
  }

  @override
  void didUpdateWidget(covariant VariantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _syncFromSelected();
    }
  }

  void _syncFromSelected() {
    final selected = widget.variants
        .where((v) => v.id == widget.selectedId)
        .firstOrNull;
    if (selected == null) return;
    final parsed = VariantAttributes.parse(selected.attributes);
    _color = parsed.color;
    _size = parsed.size;
    _model = parsed.model;
  }

  bool get _hasStructured =>
      widget.variants.any((v) => VariantAttributes.parse(v.attributes).hasAny);

  void _selectStructured({String? color, String? size, String? model}) {
    final nextColor = color ?? _color;
    final nextSize = size ?? _size;
    final nextModel = model ?? _model;

    setState(() {
      _color = nextColor;
      _size = nextSize;
      _model = nextModel;
    });

    final match = widget.variants.where((v) {
      final a = VariantAttributes.parse(v.attributes);
      if (nextColor != null && a.color != nextColor) return false;
      if (nextSize != null && a.size != nextSize) return false;
      if (nextModel != null && a.model != nextModel) return false;
      return true;
    }).where((v) => v.stock > 0).firstOrNull
        ?? widget.variants.where((v) {
          final a = VariantAttributes.parse(v.attributes);
          if (nextColor != null && a.color != nextColor) return false;
          if (nextSize != null && a.size != nextSize) return false;
          if (nextModel != null && a.model != nextModel) return false;
          return true;
        }).firstOrNull;

    if (match != null) {
      widget.onSelected(match);
    }
  }

  bool _optionAvailable({
    required String dimension,
    required String value,
  }) {
    return widget.variants.any((v) {
      if (v.stock <= 0) return false;
      final a = VariantAttributes.parse(v.attributes);
      if (dimension == 'color' && a.color != value) return false;
      if (dimension == 'size' && a.size != value) return false;
      if (dimension == 'model' && a.model != value) return false;
      if (dimension != 'color' && _color != null && a.color != _color) return false;
      if (dimension != 'size' && _size != null && a.size != _size) return false;
      if (dimension != 'model' && _model != null && a.model != _model) return false;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variants.isEmpty) return const SizedBox.shrink();

    if (_hasStructured) {
      return _StructuredVariantPicker(
        variants: widget.variants,
        color: _color,
        size: _size,
        model: _model,
        optionAvailable: _optionAvailable,
        onSelect: _selectStructured,
      );
    }

    return _NameChipPicker(
      variants: widget.variants,
      selectedId: widget.selectedId,
      onSelected: widget.onSelected,
    );
  }
}

class _StructuredVariantPicker extends StatelessWidget {
  const _StructuredVariantPicker({
    required this.variants,
    required this.color,
    required this.size,
    required this.model,
    required this.optionAvailable,
    required this.onSelect,
  });

  final List<ListingVariantEntity> variants;
  final String? color;
  final String? size;
  final String? model;
  final bool Function({required String dimension, required String value})
      optionAvailable;
  final void Function({String? color, String? size, String? model}) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = VariantAttributes.uniqueValues(variants, (a) => a.color);
    final sizes = VariantAttributes.uniqueValues(variants, (a) => a.size);
    final models = VariantAttributes.uniqueValues(variants, (a) => a.model);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('انتخاب تنوع', style: Theme.of(context).textTheme.titleSmall),
        if (colors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _AttrRow(
            label: 'رنگ',
            values: colors,
            selected: color,
            isAvailable: (v) => optionAvailable(dimension: 'color', value: v),
            onSelected: (v) => onSelect(color: v),
          ),
        ],
        if (sizes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _AttrRow(
            label: 'سایز',
            values: sizes,
            selected: size,
            isAvailable: (v) => optionAvailable(dimension: 'size', value: v),
            onSelected: (v) => onSelect(size: v),
          ),
        ],
        if (models.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _AttrRow(
            label: 'مدل',
            values: models,
            selected: model,
            isAvailable: (v) => optionAvailable(dimension: 'model', value: v),
            onSelected: (v) => onSelect(model: v),
          ),
        ],
      ],
    );
  }
}

class _AttrRow extends StatelessWidget {
  const _AttrRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.isAvailable,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String? selected;
  final bool Function(String value) isAvailable;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            final available = isAvailable(value);
            return ChoiceChip(
              label: Text(value),
              selected: selected == value,
              onSelected: available ? (_) => onSelected(value) : null,
              selectedColor: AppColors.primarySoft,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NameChipPicker extends StatelessWidget {
  const _NameChipPicker({
    required this.variants,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ListingVariantEntity> variants;
  final String? selectedId;
  final ValueChanged<ListingVariantEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,##0', 'fa');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('انتخاب تنوع', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final selected = variant.id == selectedId;
            final outOfStock = variant.stock <= 0;
            return ChoiceChip(
              label: Text(
                '${variant.name} — ${priceFormat.format(variant.price)} ${AppConstants.currencySymbol}',
              ),
              selected: selected,
              onSelected: outOfStock ? null : (_) => onSelected(variant),
              avatar: outOfStock ? const Icon(Icons.block, size: 16) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}
