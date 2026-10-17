import 'dart:typed_data';

import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/booth/data/models/booth_models.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BoothRemoteDataSource {
  Future<SellerVerificationModel?> fetchVerification(String userId);

  Future<SellerVerificationModel> upsertVerification({
    required String userId,
    required String photoUrl,
    required String fullName,
    required String idNumber,
    required String phone,
  });

  Future<String> uploadVerificationPhoto({
    required String userId,
    required List<int> bytes,
    required String extension,
  });

  Future<BoothApplicationModel> createApplication({
    required String userId,
    required BoothApplicationInput input,
  });

  Future<String> uploadApplicationAsset({
    required String userId,
    required List<int> bytes,
    required String extension,
    required String assetType,
  });

  Future<List<BoothApplicationModel>> fetchApplications(String userId);

  Future<List<BoothModel>> fetchBoothsByOwner(String userId);

  Future<BoothModel> fetchBooth(String boothId);

  Future<BoothModel> updateBooth({
    required String boothId,
    required Map<String, dynamic> updates,
  });

  Future<BoothModel> setBoothActive({
    required String boothId,
    required bool active,
  });

  Future<String> uploadBoothAsset({
    required String boothId,
    required List<int> bytes,
    required String extension,
    required String assetType,
  });
}

final class BoothRemoteDataSourceImpl implements BoothRemoteDataSource {
  BoothRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<SellerVerificationModel?> fetchVerification(String userId) async {
    try {
      final data = await _client
          .from('seller_verifications')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return SellerVerificationModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadVerificationPhoto({
    required String userId,
    required List<int> bytes,
    required String extension,
  }) async {
    try {
      final path = '$userId/verification.$extension';
      await _client.storage.from('verification-docs').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentType(extension),
            ),
          );
      // Private bucket: store object path; admins open via signed URL.
      return path;
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<SellerVerificationModel> upsertVerification({
    required String userId,
    required String photoUrl,
    required String fullName,
    required String idNumber,
    required String phone,
  }) async {
    try {
      final existing = await fetchVerification(userId);
      if (existing != null && existing.status == 'approved') {
        throw const ValidationException('احراز هویت شما قبلاً تأیید شده است.');
      }

      final payload = {
        'user_id': userId,
        'photo_url': photoUrl,
        'full_name': fullName,
        'id_number': idNumber,
        'phone': phone,
        'status': 'pending',
        'rejection_reason': null,
        'reviewed_by': null,
        'reviewed_at': null,
      };

      final data = existing == null
          ? await _client.from('seller_verifications').insert(payload).select().single()
          : await _client
              .from('seller_verifications')
              .update(payload)
              .eq('user_id', userId)
              .select()
              .single();

      return SellerVerificationModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BoothApplicationModel> createApplication({
    required String userId,
    required BoothApplicationInput input,
  }) async {
    try {
      final data = await _client
          .from('booth_applications')
          .insert({
            'user_id': userId,
            'booth_name': input.boothName,
            'slug': input.slug,
            'ownership_type': input.ownershipType.dbValue,
            'description': input.description,
            if (input.categoryId != null && input.categoryId!.isNotEmpty)
              'category_id': input.categoryId,
            'phone': input.phone,
            'address': input.address,
            'city': input.city,
            'province': input.province,
            'logo_url': input.logoUrl,
            'cover_url': input.coverUrl,
            'business_hours':
                (input.businessHours ?? BusinessHours.defaults()).toJson(),
          })
          .select()
          .single();
      return BoothApplicationModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadApplicationAsset({
    required String userId,
    required List<int> bytes,
    required String extension,
    required String assetType,
  }) async {
    try {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'applications/$userId/$assetType-$stamp.$extension';
      await _client.storage.from('booth-assets').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentType(extension),
            ),
          );
      return _client.storage.from('booth-assets').getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<BoothApplicationModel>> fetchApplications(String userId) async {
    try {
      final data = await _client
          .from('booth_applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => BoothApplicationModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<BoothModel>> fetchBoothsByOwner(String userId) async {
    try {
      final data = await _client
          .from('booths')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => BoothModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BoothModel> fetchBooth(String boothId) async {
    try {
      final data = await _client.from('booths').select().eq('id', boothId).single();
      return BoothModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BoothModel> updateBooth({
    required String boothId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final data = await _client
          .from('booths')
          .update(updates)
          .eq('id', boothId)
          .select()
          .single();
      return BoothModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BoothModel> setBoothActive({
    required String boothId,
    required bool active,
  }) async {
    try {
      final data = await _client.rpc(
        'set_booth_active',
        params: {
          'p_booth_id': boothId,
          'p_active': active,
        },
      );
      return BoothModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadBoothAsset({
    required String boothId,
    required List<int> bytes,
    required String extension,
    required String assetType,
  }) async {
    try {
      final path = '$boothId/$assetType.$extension';
      await _client.storage.from('booth-assets').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentType(extension),
            ),
          );
      return _client.storage.from('booth-assets').getPublicUrl(path);
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
