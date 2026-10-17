import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_enums.dart';
import 'package:rahmani_project/features/listing/domain/repositories/listing_repository.dart';
import 'package:rahmani_project/features/listing/presentation/providers/listing_provider.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/price_stock_form.dart';
import 'package:rahmani_project/features/listing/presentation/widgets/sku_field.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Seller adds a product to a booth as a listing.
class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({required this.boothId, super.key});

  final String boothId;

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _comparePriceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _skuController = TextEditingController();
  String? _selectedProductId;
  ListingStatus _status = ListingStatus.active;
  bool _isFeatured = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _priceController.dispose();
    _comparePriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('محصول را انتخاب کنید')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final input = ListingInput(
      productId: _selectedProductId!,
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

    final result = await ref.read(createListingProvider).call(input);
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (listing) {
        ref.invalidate(boothListingsProvider(widget.boothId));
        ref.invalidate(boothCatalogListingsProvider);
        ref.invalidate(boothBestsellersProvider(widget.boothId));
        ref.invalidate(boothNewListingsProvider(widget.boothId));
        ref.invalidate(publicBoothListingsProvider);
        context.pushReplacement(
          RouteNames.sellerBoothListingEdit(widget.boothId, listing.id),
        );
        final selected = ref
            .read(myProductsProvider)
            .valueOrNull
            ?.where((p) => p.id == listing.productId)
            .firstOrNull;
        final pendingNote = selected?.isPendingApproval == true
            ? ' — پس از تأیید ادمین در فروشگاه عمومی دیده می‌شود'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لیستینگ ایجاد شد$pendingNote'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('افزودن لیستینگ')),
      body: productsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(error: e),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ابتدا یک محصول در کاتالوگ بسازید، سپس آن را به این فروشگاه اضافه کنید.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push(RouteNames.sellerProductCreate),
                      child: const Text('ایجاد محصول'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProductId,
                  decoration: const InputDecoration(
                    labelText: 'محصول',
                    border: OutlineInputBorder(),
                  ),
                  items: products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.isApproved
                                ? p.name
                                : '${p.name} (${p.approvalLabelFa})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedProductId = value),
                  validator: (value) {
                    if (value == null) return 'محصول الزامی است';
                    final product = products.where((p) => p.id == value).firstOrNull;
                    if (product != null && !product.isApproved) {
                      return 'این محصول هنوز تأیید نشده و در فروشگاه عمومی نمایش داده نمی‌شود';
                    }
                    return null;
                  },
                ),
                if (_selectedProductId != null) ...[
                  Builder(
                    builder: (context) {
                      final selected = products
                          .where((p) => p.id == _selectedProductId)
                          .firstOrNull;
                      if (selected == null || selected.isApproved) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          selected.isRejected
                              ? 'محصول رد شده است${selected.rejectionReason != null ? ': ${selected.rejectionReason}' : ''}'
                              : 'محصول در انتظار تأیید ادمین است و تا تأیید در صفحه عمومی فروشگاه دیده نمی‌شود.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                PriceStockForm(
                  priceController: _priceController,
                  comparePriceController: _comparePriceController,
                  stockController: _stockController,
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
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ذخیره'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}