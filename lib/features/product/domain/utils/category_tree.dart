import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';

/// Builds a hierarchical category tree from a flat list.
List<CategoryEntity> buildCategoryTree(List<CategoryEntity> flat) {
  final childrenMap = <String, List<CategoryEntity>>{};

  for (final category in flat) {
    if (category.parentId != null) {
      childrenMap.putIfAbsent(category.parentId!, () => []).add(category);
    }
  }

  CategoryEntity withChildren(CategoryEntity category) {
    final children = childrenMap[category.id] ?? [];
    children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return CategoryEntity(
      id: category.id,
      name: category.name,
      slug: category.slug,
      parentId: category.parentId,
      iconUrl: category.iconUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
      children: children.map(withChildren).toList(),
    );
  }

  final roots = flat.where((c) => c.parentId == null).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  return roots.map(withChildren).toList();
}

/// Flattens a category tree for display with indentation level.
List<({CategoryEntity category, int depth})> flattenCategoryTree(
  List<CategoryEntity> roots,
) {
  final result = <({CategoryEntity category, int depth})>[];

  void walk(CategoryEntity category, int depth) {
    result.add((category: category, depth: depth));
    for (final child in category.children) {
      walk(child, depth + 1);
    }
  }

  for (final root in roots) {
    walk(root, 0);
  }
  return result;
}
