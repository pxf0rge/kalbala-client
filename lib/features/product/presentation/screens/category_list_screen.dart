import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/product/domain/utils/category_tree.dart';
import 'package:rahmani_project/features/product/presentation/providers/product_provider.dart';
import 'package:rahmani_project/features/product/presentation/widgets/category_tile.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Browse categories hierarchically.
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('دسته‌بندی‌ها')),
      body: categoriesAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری دسته‌ها...'),
        error: (e, _) => AppAsyncError(error: e),
        data: (roots) {
          final flat = flattenCategoryTree(roots);
          return ListView.builder(
            itemCount: flat.length,
            itemBuilder: (context, index) {
              final item = flat[index];
              return CategoryTile(category: item.category, depth: item.depth);
            },
          );
        },
      ),
    );
  }
}