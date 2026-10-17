import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/entities/product_entity.dart';
import 'package:rahmani_project/features/product/domain/repositories/product_repository.dart';
import 'package:rahmani_project/features/product/domain/utils/category_tree.dart';

class GetCategories {
  const GetCategories(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() async {
    final result = await _repository.getCategories();
    return result.map(buildCategoryTree);
  }
}

class GetCategoryProducts {
  const GetCategoryProducts(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call(String categoryId) =>
      _repository.getCategoryProducts(categoryId);
}

class GetMyProducts {
  const GetMyProducts(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call() => _repository.getMyProducts();
}

class CreateProduct {
  const CreateProduct(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call(
    ProductInput input, {
    void Function(double progress, String message)? onProgress,
  }) {
    if (input.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('نام محصول الزامی است.')));
    }
    if (input.weightGrams < 0) {
      return Future.value(const Left(ValidationFailure('وزن محصول نامعتبر است.')));
    }
    return _repository.createProduct(
      ProductInput(
        name: input.name.trim(),
        description: input.description?.trim(),
        categoryId: input.categoryId,
        brand: input.brand?.trim(),
        weightGrams: input.weightGrams,
        hasVariants: input.hasVariants,
        imageBytesList: input.imageBytesList,
        imageExtensions: input.imageExtensions,
      ),
      onProgress: onProgress,
    );
  }
}

class UpdateProduct {
  const UpdateProduct(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call({
    required String productId,
    required ProductInput input,
    List<String>? existingImages,
    void Function(double progress, String message)? onProgress,
  }) {
    if (input.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('نام محصول الزامی است.')));
    }
    return _repository.updateProduct(
      productId: productId,
      input: input,
      existingImages: existingImages,
      onProgress: onProgress,
    );
  }
}

class DeleteProduct {
  const DeleteProduct(this._repository);
  final ProductRepository _repository;

  Future<Either<Failure, void>> call(String productId) =>
      _repository.deleteProduct(productId);
}
