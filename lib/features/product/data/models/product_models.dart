import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/entities/product_entity.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      parentId: json['parent_id'] as String?,
      iconUrl: json['icon_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      slug: slug,
      parentId: parentId,
      iconUrl: iconUrl,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.description,
    this.categoryId,
    this.brand,
    this.weightGrams = 0,
    this.hasVariants = false,
    this.images = const [],
    this.isBlocked = false,
    this.approvalStatus = 'approved',
    this.rejectionReason,
  });

  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? brand;
  final int weightGrams;
  final bool hasVariants;
  final List<String> images;
  final String createdBy;
  final bool isBlocked;
  final String approvalStatus;
  final String? rejectionReason;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      brand: json['brand'] as String?,
      weightGrams: json['weight_grams'] as int? ?? 0,
      hasVariants: json['has_variants'] as bool? ?? false,
      images: images,
      createdBy: json['created_by'] as String,
      isBlocked: json['is_blocked'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'approved',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'brand': brand,
      'weight_grams': weightGrams,
      'has_variants': hasVariants,
      'images': images,
      'created_by': userId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'brand': brand,
      'weight_grams': weightGrams,
      'has_variants': hasVariants,
      'images': images,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      categoryId: categoryId,
      brand: brand,
      weightGrams: weightGrams,
      hasVariants: hasVariants,
      images: images,
      createdBy: createdBy,
      isBlocked: isBlocked,
      approvalStatus: approvalStatus,
      rejectionReason: rejectionReason,
    );
  }
}
