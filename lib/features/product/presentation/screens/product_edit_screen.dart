import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/features/product/domain/repositories/product_repository.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/features/product/presentation/widgets/product_form.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Edit an existing catalog product.
class ProductEditScreen extends ConsumerWidget {
  const ProductEditScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش محصول')),
      body: productAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(error: e),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('محصول یافت نشد'));
          }

          return ProductForm(
            initialName: product.name,
            initialDescription: product.description ?? '',
            initialBrand: product.brand ?? '',
            initialWeightGrams: product.weightGrams,
            initialHasVariants: product.hasVariants,
            initialCategoryId: product.categoryId,
            existingImageUrls: product.images,
            submitLabel: 'به‌روزرسانی',
            onSubmit: ({
              required name,
              required description,
              required brand,
              required weightGrams,
              required hasVariants,
              required categoryId,
              required keptImageUrls,
              required newImageBytes,
              required newImageExtensions,
              onProgress,
            }) async {
              final result = await ref.read(updateProductProvider).call(
                    productId: productId,
                    input: ProductInput(
                      name: name,
                      description: (description?.isEmpty ?? true) ? null : description,
                      brand: (brand?.isEmpty ?? true) ? null : brand,
                      weightGrams: weightGrams,
                      hasVariants: hasVariants,
                      categoryId: categoryId,
                      imageBytesList: newImageBytes.map((b) => b.toList()).toList(),
                      imageExtensions: newImageExtensions,
                    ),
                    existingImages: keptImageUrls,
                    onProgress: onProgress,
                  );
              return result.fold(
                (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                  }
                  return false;
                },
                (_) {
                  ref.invalidate(myProductsProvider);
                  ref.invalidate(productDetailProvider(productId));
                  if (context.mounted) context.pop();
                  return true;
                },
              );
            },
          );
        },
      ),
    );
  }
}