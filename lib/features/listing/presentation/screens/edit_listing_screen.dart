import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';
import 'package:rahmani_project/features/listing/domain/repositories/listing_repository.dart';
import 'package:rahmani_project/features/listing/domain/utils/variant_attributes.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/price_stock_form.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/sku_field.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/variant_attributes_fields.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Seller edits an existing booth listing and manages variants.
class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({
    required this.boothId,
    required this.listingId,
    super.key,
  });

  final String boothId;
  final String listingId;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _comparePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  ListingStatus _status = ListingStatus.active;
  bool _isFeatured = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _priceController.dispose();
    _comparePriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _initFromListing(ListingEntity listing) {
    if (_initialized) return;
    _priceController.text = listing.price.toString();
    _comparePriceController.text = listing.compareAtPrice?.toString() ?? '';
    _stockController.text = listing.stock.toString();
    _skuController.text = listing.sku ?? '';
    _status = listing.status;
    _isFeatured = listing.isFeatured;
    _initialized = true;
  }

  Future<void> _submit({required bool hasVariants}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final input = ListingInput(
      productId: '',
      boothId: widget.boothId,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      status: _status,
      isFeatured: _isFeatured,
      compareAtPrice: _comparePriceController.text.trim().isEmpty
          ? null
          : double.parse(_comparePriceController.text),
    );

    final result = await ref.read(updateListingProvider).call(
          listingId: widget.listingId,
          input: input,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(boothListingsProvider(widget.boothId));
        ref.invalidate(listingDetailProvider(widget.listingId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasVariants
                  ? 'لیستینگ به‌روزرسانی شد (موجودی کل از تنوع‌ها همگام می‌شود)'
                  : 'لیستینگ به‌روزرسانی شد',
            ),
          ),
        );
      },
    );
  }

  Future<void> _openVariantEditor({ListingVariantEntity? existing}) async {
    final parsed = existing != null
        ? VariantAttributes.parse(existing.attributes)
        : const VariantAttributes();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing != null ? existing.price.toString() : '',
    );
    final comparePriceController = TextEditingController(
      text: existing?.compareAtPrice?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: existing != null ? existing.stock.toString() : '0',
    );
    final skuController = TextEditingController(text: existing?.sku ?? '');
    final colorController = TextEditingController(text: parsed.color ?? '');
    final sizeController = TextEditingController(text: parsed.size ?? '');
    final modelController = TextEditingController(text: parsed.model ?? '');
    final variantFormKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'افزودن تنوع' : 'ویرایش تنوع'),
        content: Form(
          key: variantFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام نمایشی',
                    hintText: 'خالی = از رنگ/سایز/مدل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                VariantAttributesFields(
                  colorController: colorController,
                  sizeController: sizeController,
                  modelController: modelController,
                ),
                const SizedBox(height: 12),
                PriceStockForm(
                  priceController: priceController,
                  comparePriceController: comparePriceController,
                  stockController: stockController,
                ),
                const SizedBox(height: 12),
                SkuField(controller: skuController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          FilledButton(
            onPressed: () {
              if (variantFormKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(existing == null ? 'افزودن' : 'ذخیره'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    final attrs = VariantAttributesFields.collect(
      colorController: colorController,
      sizeController: sizeController,
      modelController: modelController,
    );
    final attrsParsed = VariantAttributes.parse(attrs);
    final name = nameController.text.trim().isEmpty
        ? attrsParsed.suggestedName()
        : nameController.text.trim();

    final input = VariantInput(
      name: name,
      price: double.parse(priceController.text),
      stock: int.parse(stockController.text),
      attributes: attrs,
      sku: skuController.text.trim().isEmpty ? null : skuController.text.trim(),
      compareAtPrice: comparePriceController.text.trim().isEmpty
          ? null
          : double.parse(comparePriceController.text),
    );

    final result = existing == null
        ? await ref.read(addVariantProvider).call(
              listingId: widget.listingId,
              input: input,
            )
        : await ref.read(updateVariantProvider).call(
              variantId: existing.id,
              input: input,
            );

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(listingDetailProvider(widget.listingId));
        ref.invalidate(boothListingsProvider(widget.boothId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing == null ? 'تنوع اضافه شد' : 'تنوع به‌روزرسانی شد'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش لیستینگ')),
      body: listingAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(error: e),
        data: (listing) {
          if (listing == null) return const Center(child: Text('لیستینگ یافت نشد'));
          _initFromListing(listing);
          final hasVariants = listing.variants.isNotEmpty;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  listing.productName ?? 'محصول',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                PriceStockForm(
                  priceController: _priceController,
                  comparePriceController: _comparePriceController,
                  stockController: _stockController,
                  stockEnabled: !hasVariants,
                  stockHelperText: hasVariants
                      ? 'موجودی کل = جمع موجودی تنوع‌ها (از پایین ویرایش کنید)'
                      : null,
                ),
                const SizedBox(height: 16),
                SkuField(controller: _skuController),
                const SizedBox(height: 16),
                DropdownButtonFormField<ListingStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'وضعیت',
                    border: OutlineInputBorder(),
                    helperText: 'غیرفعال = مخفی از خریدار',
                  ),
                  items: ListingStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.labelFa)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('لیستینگ ویژه'),
                  value: _isFeatured,
                  onChanged: (value) => setState(() => _isFeatured = value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSaving ? null : () => _submit(hasVariants: hasVariants),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ذخیره تغییرات'),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تنوع‌ها', style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => _openVariantEditor(),
                      icon: const Icon(Icons.add),
                      label: const Text('افزودن'),
                    ),
                  ],
                ),
                Text(
                  'رنگ، سایز و مدل برای انتخاب روی صفحه محصول استفاده می‌شوند.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (listing.variants.isEmpty)
                  const Text('تنوعی ثبت نشده — موجودی از فیلد بالا استفاده می‌شود')
                else
                  ...listing.variants.map((v) {
                    final attrs = VariantAttributes.parse(v.attributes);
                    final subtitleParts = <String>[
                      '${v.price}',
                      'موجودی: ${v.stock}',
                      if (attrs.color != null) 'رنگ: ${attrs.color}',
                      if (attrs.size != null) 'سایز: ${attrs.size}',
                      if (attrs.model != null) 'مدل: ${attrs.model}',
                    ];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(v.name),
                      subtitle: Text(subtitleParts.join(' • ')),
                      onTap: () => _openVariantEditor(existing: v),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openVariantEditor(existing: v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final result =
                                  await ref.read(deleteVariantProvider).call(v.id);
                              if (!context.mounted) return;
                              result.fold(
                                (f) => ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(f.message)),
                                ),
                                (_) {
                                  ref.invalidate(
                                    listingDetailProvider(widget.listingId),
                                  );
                                  ref.invalidate(
                                    boothListingsProvider(widget.boothId),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}