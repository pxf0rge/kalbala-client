import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/product/domain/repositories/product_repository.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/features/product/presentation/widgets/product_form.dart';

/// Create a new catalog product.
class ProductCreateScreen extends ConsumerWidget {
  const ProductCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booths = ref.watch(myBoothsProvider).valueOrNull ?? [];
    final canCreate = booths.any(
      (b) => b.approvalStatus == ApprovalStatus.approved && !b.isBlocked,
    );

    if (!canCreate) {
      return Scaffold(
        appBar: AppBar(title: const Text('محصول جدید')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'برای ثبت محصول، ابتدا باید فروشگاه شما توسط ادمین تأیید شود.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(RouteNames.seller),
                  child: const Text('بازگشت به پنل فروشنده'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('محصول جدید')),
      body: ProductForm(
        submitLabel: 'ایجاد محصول',
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
          final result = await ref.read(createProductProvider).call(
                ProductInput(
                  name: name,
                  description: (description?.isEmpty ?? true) ? null : description,
                  brand: (brand?.isEmpty ?? true) ? null : brand,
                  weightGrams: weightGrams,
                  hasVariants: hasVariants,
                  categoryId: categoryId,
                  imageBytesList: newImageBytes.map((b) => b.toList()).toList(),
                  imageExtensions: newImageExtensions,
                ),
                onProgress: onProgress,
              );

          final failure = result.fold((f) => f, (_) => null);
          if (failure != null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
            return false;
          }

          ref.invalidate(myProductsProvider);
          if (!context.mounted) return true;

          final addToBooth = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('محصول ایجاد شد'),
              content: const Text(
                'برای فروش، محصول را به یکی از فروشگاه‌ها به‌عنوان لیستینگ اضافه کنید.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('بعداً'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('افزودن به فروشگاه'),
                ),
              ],
            ),
          );

          if (!context.mounted) return true;
          context.pop();
          if (addToBooth == true) {
            context.push(RouteNames.sellerBooths);
          }
          return true;
        },
      ),
    );
  }
}
