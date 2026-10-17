import 'dart:typed_data';

import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/product/data/models/product_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<CategoryModel>> fetchCategories();

  Future<List<ProductModel>> fetchProductsByCategory(String categoryId);

  Future<List<ProductModel>> fetchProductsByCreator(String userId);

  Future<ProductModel> fetchProduct(String productId);

  Future<ProductModel> insertProduct(ProductModel product, String userId);

  Future<ProductModel> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);

  Future<String> uploadProductImage({
    required String productId,
    required List<int> bytes,
    required String extension,
    required int index,
  });
}

final class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _productSelect =
      'id, name, description, category_id, brand, weight_grams, has_variants, images, created_by, is_blocked, approval_status, rejection_reason';

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      return (data as List<dynamic>)
          .map((row) => CategoryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      final data = await _client
          .from('products')
          .select(_productSelect)
          .eq('category_id', categoryId)
          .eq('is_blocked', false)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<ProductModel>> fetchProductsByCreator(String userId) async {
    try {
      final data = await _client
          .from('products')
          .select(_productSelect)
          .eq('created_by', userId)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ProductModel> fetchProduct(String productId) async {
    try {
      final data = await _client
          .from('products')
          .select(_productSelect)
          .eq('id', productId)
          .single();
      return ProductModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ProductModel> insertProduct(ProductModel product, String userId) async {
    try {
      final data = await _client
          .from('products')
          .insert(product.toInsertJson(userId))
          .select(_productSelect)
          .single();
      return ProductModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final data = await _client
          .from('products')
          .update(product.toUpdateJson())
          .eq('id', product.id)
          .select(_productSelect)
          .single();
      return ProductModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadProductImage({
    required String productId,
    required List<int> bytes,
    required String extension,
    required int index,
  }) async {
    try {
      final path = '$productId/image_$index.$extension';
      await _client.storage.from('product-images').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentType(extension),
            ),
          );
      return _client.storage.from('product-images').getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  String _contentType(String ext) {
    return switch (ext.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
