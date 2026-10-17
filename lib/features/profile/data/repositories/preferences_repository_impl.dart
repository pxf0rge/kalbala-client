import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/data/datasources/preferences_remote_datasource.dart';
import 'package:rahmani_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/preferences_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl({
    required PreferencesRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final PreferencesRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, UserPreferencesEntity>> getPreferences() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final json = await _remote.fetchPreferences();
      return Right(preferencesFromJson(json));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updatePreferences({
    bool? promoNotifications,
    String? locale,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final json = await _remote.upsertPreferences(
        promoNotifications: promoNotifications,
        locale: locale,
      );
      return Right(preferencesFromJson(json));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredPreferencesRepository implements PreferencesRepository {
  const UnconfiguredPreferencesRepository();

  static const _message = 'سرویس پیکربندی نشده است';

  @override
  Future<Either<Failure, UserPreferencesEntity>> getPreferences() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, UserPreferencesEntity>> updatePreferences({
    bool? promoNotifications,
    String? locale,
  }) async =>
      const Left(AuthFailure(_message));
}
