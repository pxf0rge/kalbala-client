import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/search/presentation/providers/search_provider.dart';

/// Bottom sheet for search filters (category, price range).
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _categoryId;
  bool _initialized = false;

  void _initFromFilters() {
    if (_initialized) return;
    final filters = ref.read(searchFiltersProvider);
    _categoryId = filters.categoryId;
    if (filters.minPrice != null) _minPriceController.text = filters.minPrice!.toStringAsFixed(0);
    if (filters.maxPrice != null) _maxPriceController.text = filters.maxPrice!.toStringAsFixed(0);
    _initialized = true;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    ref.read(searchFiltersProvider.notifier).applyFilters(
          categoryId: _categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
    Navigator.pop(context);
  }

  void _clear() {
    ref.read(searchFiltersProvider.notifier).clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _initFromFilters();
    final categoriesAsync = ref.watch(homeFeedProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('فیلترها', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('خطا در بارگذاری دسته‌ها'),
                data: (feed) {
                  final categories = feed?.categories ?? [];
                  return DropdownButtonFormField<String?>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'دسته‌بندی',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('همه دسته‌ها')),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _categoryId = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'حداقل قیمت',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'حداکثر قیمت',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(onPressed: _clear, child: const Text('پاک کردن')),
                  const Spacer(),
                  FilledButton(onPressed: _apply, child: const Text('اعمال')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
