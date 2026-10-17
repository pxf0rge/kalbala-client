import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/entities/product_entity.dart';

class ProductInput {
  const ProductInput({
    required this.name,
    this.description,
    this.categoryId,
    this.brand,
    this.weightGrams = 0,
    this.hasVariants = false,
    this.imageBytesList = const [],
    this.imageExtensions = const [],
  });

  final String name;
  final String? description;
  final String? categoryId;
  final String? brand;
  final int weightGrams;
  final bool hasVariants;
  final List<List<int>> imageBytesList;
  final List<String> imageExtensions;
}

abstract interface class ProductRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<ProductEntity>>> getCategoryProducts(String categoryId);

  Future<Either<Failure, List<ProductEntity>>> getMyProducts();

  Future<Either<Failure, ProductEntity>> getProduct(String productId);

  Future<Either<Failure, ProductEntity>> createProduct(
    ProductInput input, {
    void Function(double progress, String message)? onProgress,
  });

  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    required ProductInput input,
    List<String>? existingImages,
    void Function(double progress, String message)? onProgress,
  });

  Future<Either<Failure, void>> deleteProduct(String productId);
}
