import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/product/data/datasources/product_remote_datasource.dart';
import 'package:rahmani_project/features/product/data/models/product_models.dart';
import 'package:rahmani_project/features/product/domain/entities/category_entity.dart';
import 'package:rahmani_project/features/product/domain/entities/product_entity.dart';
import 'package:rahmani_project/features/product/domain/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ProductRemoteDataSource _remote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _remote.fetchCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCategoryProducts(
    String categoryId,
  ) async {
    try {
      final models = await _remote.fetchProductsByCategory(categoryId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyProducts() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final models = await _remote.fetchProductsByCreator(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String productId) async {
    try {
      final model = await _remote.fetchProduct(productId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductInput input, {
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      report(0.05, 'در حال ثبت محصول…');
      var product = await _remote.insertProduct(
        ProductModel(
          id: '',
          name: input.name,
          description: input.description,
          categoryId: input.categoryId,
          brand: input.brand,
          weightGrams: input.weightGrams,
          hasVariants: input.hasVariants,
          createdBy: userId,
        ),
        userId,
      );

      final imageUrls = await _uploadImages(
        productId: product.id,
        bytesList: input.imageBytesList,
        extensions: input.imageExtensions,
        startIndex: 0,
        onProgress: onProgress,
        progressStart: 0.15,
        progressEnd: 0.85,
      );

      if (imageUrls.isNotEmpty) {
        report(0.9, 'در حال ذخیره تصاویر…');
        product = await _remote.updateProduct(
          ProductModel(
            id: product.id,
            name: product.name,
            description: product.description,
            categoryId: product.categoryId,
            brand: product.brand,
            weightGrams: product.weightGrams,
            hasVariants: product.hasVariants,
            images: imageUrls,
            createdBy: product.createdBy,
          ),
        );
      }

      report(1, 'محصول ثبت شد');
      return Right(product.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    required ProductInput input,
    List<String>? existingImages,
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      report(0.05, 'در حال آماده‌سازی…');
      final current = await _remote.fetchProduct(productId);
      final keptImages = existingImages ?? current.images;

      final newUrls = await _uploadImages(
        productId: productId,
        bytesList: input.imageBytesList,
        extensions: input.imageExtensions,
        startIndex: keptImages.length,
        onProgress: onProgress,
        progressStart: 0.1,
        progressEnd: 0.8,
      );

      report(0.85, 'در حال ذخیره محصول…');
      final product = await _remote.updateProduct(
        ProductModel(
          id: productId,
          name: input.name,
          description: input.description,
          categoryId: input.categoryId,
          brand: input.brand,
          weightGrams: input.weightGrams,
          hasVariants: input.hasVariants,
          images: [...keptImages, ...newUrls],
          createdBy: current.createdBy,
        ),
      );
      report(1, 'ذخیره شد');
      return Right(product.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await _remote.deleteProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<List<String>> _uploadImages({
    required String productId,
    required List<List<int>> bytesList,
    required List<String> extensions,
    required int startIndex,
    void Function(double progress, String message)? onProgress,
    double progressStart = 0,
    double progressEnd = 1,
  }) async {
    final urls = <String>[];
    if (bytesList.isEmpty) return urls;

    final span = (progressEnd - progressStart).clamp(0.0, 1.0);
    for (var i = 0; i < bytesList.length; i++) {
      final step = progressStart + span * (i / bytesList.length);
      onProgress?.call(
        step.clamp(0.0, 1.0),
        'آپلود تصویر ${i + 1} از ${bytesList.length}…',
      );
      final ext = i < extensions.length ? extensions[i] : 'jpg';
      final url = await _remote.uploadProductImage(
        productId: productId,
        bytes: bytesList[i],
        extension: ext,
        index: startIndex + i,
      );
      urls.add(url);
    }
    onProgress?.call(progressEnd.clamp(0.0, 1.0), 'آپلود تصاویر تمام شد');
    return urls;
  }
}

final class UnconfiguredProductRepository implements ProductRepository {
  const UnconfiguredProductRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<ProductEntity>>> getCategoryProducts(String categoryId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyProducts() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String productId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductInput input, {
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    required ProductInput input,
    List<String>? existingImages,
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async =>
      const Left(AuthFailure(_message));
}
