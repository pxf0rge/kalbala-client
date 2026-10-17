import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FavoritesRemoteDataSource {
  Future<List<dynamic>> fetchFavorites();

  Future<bool> checkFavorited(String listingId);

  Future<void> insertFavorite(String listingId);

  Future<void> deleteFavorite(String listingId);

  Future<List<dynamic>> fetchFollowedBooths();

  Future<bool> checkFollowing(String boothId);

  Future<void> insertFollow(String boothId);

  Future<void> deleteFollow(String boothId);
}

final class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  FavoritesRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<dynamic>> fetchFavorites() async {
    try {
      final data = await _client.rpc('get_user_favorites');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<bool> checkFavorited(String listingId) async {
    try {
      final userId = _userId;
      if (userId == null) return false;
      final data = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .maybeSingle();
      return data != null;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> insertFavorite(String listingId) async {
    try {
      final userId = _userId;
      if (userId == null) throw const app_errors.AuthException('Not authenticated');
      await _client.from('favorites').insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> deleteFavorite(String listingId) async {
    try {
      final userId = _userId;
      if (userId == null) throw const app_errors.AuthException('Not authenticated');
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchFollowedBooths() async {
    try {
      final data = await _client.rpc('get_followed_booths');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<bool> checkFollowing(String boothId) async {
    try {
      final userId = _userId;
      if (userId == null) return false;
      final data = await _client
          .from('booth_follows')
          .select('id')
          .eq('user_id', userId)
          .eq('booth_id', boothId)
          .maybeSingle();
      return data != null;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> insertFollow(String boothId) async {
    try {
      final userId = _userId;
      if (userId == null) throw const app_errors.AuthException('Not authenticated');
      await _client.from('booth_follows').insert({
        'user_id': userId,
        'booth_id': boothId,
      });
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> deleteFollow(String boothId) async {
    try {
      final userId = _userId;
      if (userId == null) throw const app_errors.AuthException('Not authenticated');
      await _client
          .from('booth_follows')
          .delete()
          .eq('user_id', userId)
          .eq('booth_id', boothId);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
