import 'package:flutter/material.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';

/// Tile for displaying a category in a list.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.depth,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final CategoryEntity category;
  final int depth;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(start: 16.0 + depth * 20, end: 16),
      leading: Icon(
        category.children.isEmpty ? Icons.category_outlined : Icons.folder_outlined,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        category.name,
        style: selected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
      ),
      trailing: selected ? const Icon(Icons.check, size: 20) : null,
      onTap: onTap,
    );
  }
}
