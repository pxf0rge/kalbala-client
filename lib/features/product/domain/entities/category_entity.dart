/// Product category with optional parent for hierarchy.
class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.children = const [],
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;
  final List<CategoryEntity> children;

  bool get isRoot => parentId == null;
}
