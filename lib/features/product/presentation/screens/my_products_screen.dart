import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Seller's product catalog list.
class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);
    final booths = ref.watch(myBoothsProvider).valueOrNull ?? [];
    final canCreate = booths.any(
      (b) => b.approvalStatus == ApprovalStatus.approved && !b.isBlocked,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('محصولات من')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!canCreate) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'برای ثبت محصول باید حداقل یک فروشگاه تأییدشده داشته باشید.',
                ),
              ),
            );
            return;
          }
          context.push(RouteNames.sellerProductCreate);
        },
        icon: const Icon(Icons.add),
        label: const Text('محصول جدید'),
      ),
      body: productsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری محصولات...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (products) {
          if (products.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'محصولی ثبت نشده',
              subtitle: 'محصولات در کاتالوگ سراسری ذخیره می‌شوند. برای فروش، آن‌ها را از بخش لیستینگ فروشگاه اضافه کنید.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(myProductsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: product.primaryImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product.primaryImage!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_outlined),
                    title: Text(product.name),
                    subtitle: Text(
                      [
                        product.approvalLabelFa,
                        '${product.weightGrams} گرم',
                        if (product.hasVariants) 'دارای تنوع',
                      ].join(' • '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          context.push(RouteNames.sellerProductEdit(product.id));
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('حذف محصول'),
                              content: Text('«${product.name}» حذف شود؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('انصراف'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await ref.read(myProductsProvider.notifier).remove(product.id);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                        const PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                    onTap: () => context.push(RouteNames.sellerProductEdit(product.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}