import 'dart:typed_data';

import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/profile/data/models/profile_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> fetchProfile(String userId);

  Future<ProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });

  Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
  });
}

abstract interface class AddressRemoteDataSource {
  Future<List<AddressModel>> fetchAddresses(String userId);

  Future<AddressModel> insertAddress(AddressModel address);

  Future<AddressModel> updateAddress(AddressModel address);

  Future<void> deleteAddress(String addressId);

  Future<AddressModel> setDefaultAddress({
    required String userId,
    required String addressId,
  });
}

final class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('id, phone, full_name, avatar_url, is_seller')
          .eq('id', userId)
          .single();
      return ProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        return await fetchProfile(userId);
      }

      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select('id, phone, full_name, avatar_url, is_seller')
          .single();
      return ProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    try {
      final path = '$userId/avatar.$fileExtension';
      await _client.storage.from('avatars').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeForExtension(fileExtension),
            ),
          );
      // Same storage path after upsert — bust CDN / CachedNetworkImage cache.
      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      return publicUrl.contains('?')
          ? '$publicUrl&v=$stamp'
          : '$publicUrl?v=$stamp';
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  String _contentTypeForExtension(String ext) {
    return switch (ext.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

final class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  AddressRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AddressModel>> fetchAddresses(String userId) async {
    try {
      final data = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return (data as List<dynamic>)
          .map((row) => AddressModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<AddressModel> insertAddress(AddressModel address) async {
    try {
      final data = await _client
          .from('addresses')
          .insert(address.toInsertJson(address.userId))
          .select()
          .single();
      return AddressModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final data = await _client
          .from('addresses')
          .update(address.toUpdateJson())
          .eq('id', address.id)
          .eq('user_id', address.userId)
          .select()
          .single();
      return AddressModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await _client.from('addresses').delete().eq('id', addressId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<AddressModel> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      final data = await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId)
          .eq('user_id', userId)
          .select()
          .single();
      return AddressModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
