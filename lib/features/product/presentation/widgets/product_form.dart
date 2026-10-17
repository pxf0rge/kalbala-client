import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/utils/category_tree.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/features/product/presentation/widgets/category_tile.dart';
import 'package:rahmani_project/features/product/presentation/widgets/image_picker_grid.dart';
import 'package:rahmani_project/shared/widgets/app_upload_progress_bar.dart';

/// Shared product create/edit form fields.
class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({
    required this.onSubmit,
    this.initialName = '',
    this.initialDescription = '',
    this.initialBrand = '',
    this.initialWeightGrams = 0,
    this.initialHasVariants = false,
    this.initialCategoryId,
    this.existingImageUrls = const [],
    this.submitLabel = 'ذخیره',
    super.key,
  });

  final String initialName;
  final String initialDescription;
  final String initialBrand;
  final int initialWeightGrams;
  final bool initialHasVariants;
  final String? initialCategoryId;
  final List<String> existingImageUrls;
  final String submitLabel;
  final Future<bool> Function({
    required String name,
    required String? description,
    required String? brand,
    required int weightGrams,
    required bool hasVariants,
    required String? categoryId,
    required List<String> keptImageUrls,
    required List<Uint8List> newImageBytes,
    required List<String> newImageExtensions,
    void Function(double progress, String message)? onProgress,
  }) onSubmit;

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _brandController;
  late final TextEditingController _weightController;
  late bool _hasVariants;
  String? _categoryId;
  List<String> _keptUrls = [];
  List<Uint8List> _newBytes = [];
  List<String> _newExtensions = [];
  bool _isSaving = false;
  double? _uploadProgress;
  String _uploadMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _brandController = TextEditingController(text: widget.initialBrand);
    _weightController = TextEditingController(
      text: widget.initialWeightGrams > 0 ? '${widget.initialWeightGrams}' : '',
    );
    _hasVariants = widget.initialHasVariants;
    _categoryId = widget.initialCategoryId;
    _keptUrls = List.from(widget.existingImageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory(List<CategoryEntity> roots) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final flat = flattenCategoryTree(roots);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('انتخاب دسته‌بندی')),
              for (final item in flat)
                CategoryTile(
                  category: item.category,
                  depth: item.depth,
                  selected: item.category.id == _categoryId,
                  onTap: () => Navigator.pop(context, item.category.id),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _categoryId = selected);
  }

  String? _categoryName(List<CategoryEntity> roots) {
    if (_categoryId == null) return null;
    for (final item in flattenCategoryTree(roots)) {
      if (item.category.id == _categoryId) return item.category.name;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_keptUrls.isEmpty && _newBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل یک تصویر برای محصول لازم است')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _uploadProgress = 0;
      _uploadMessage = 'شروع ذخیره…';
    });
    final success = await widget.onSubmit(
      name: _nameController.text,
      description: _descriptionController.text,
      brand: _brandController.text,
      weightGrams: int.tryParse(_weightController.text) ?? 0,
      hasVariants: _hasVariants,
      categoryId: _categoryId,
      keptImageUrls: _keptUrls,
      newImageBytes: _newBytes,
      newImageExtensions: _newExtensions,
      onProgress: (progress, message) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = progress;
          _uploadMessage = message;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _uploadProgress = null;
      _uploadMessage = '';
    });
    if (!success && mounted) {
      // Specific failure snack already shown by callers when available.
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.valueOrNull != null
        ? _categoryName(categoriesAsync.valueOrNull!)
        : null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            decoration: const InputDecoration(
              labelText: 'نام محصول *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'الزامی' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            enabled: !_isSaving,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'توضیحات',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('دسته‌بندی'),
            subtitle: Text(categoryName ?? 'انتخاب نشده'),
            trailing: const Icon(Icons.chevron_left),
            onTap: (!_isSaving && categoriesAsync.hasValue)
                ? () => _pickCategory(categoriesAsync.value!)
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _brandController,
            enabled: !_isSaving,
            decoration: const InputDecoration(
              labelText: 'برند (اختیاری)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            enabled: !_isSaving,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'وزن (گرم)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('دارای تنوع (رنگ/سایز/مدل)'),
            subtitle: const Text('قیمت و موجودی هر تنوع در لیستینگ فروشگاه تنظیم می‌شود'),
            value: _hasVariants,
            onChanged: _isSaving ? null : (v) => setState(() => _hasVariants = v),
          ),
          const SizedBox(height: 16),
          ImagePickerGrid(
            existingImageUrls: widget.existingImageUrls,
            enabled: !_isSaving,
            onChanged: ({required keptUrls, required newBytes, required newExtensions}) {
              setState(() {
                _keptUrls = keptUrls;
                _newBytes = newBytes;
                _newExtensions = newExtensions;
              });
            },
          ),
          if (_isSaving && _uploadProgress != null) ...[
            const SizedBox(height: 16),
            AppUploadProgressBar(
              progress: _uploadProgress!,
              message: _uploadMessage,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isSaving ? 'در حال ذخیره…' : widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
