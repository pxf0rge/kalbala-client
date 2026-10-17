import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/domain/entities/user_preferences_entity.dart';

abstract interface class PreferencesRepository {
  Future<Either<Failure, UserPreferencesEntity>> getPreferences();

  Future<Either<Failure, UserPreferencesEntity>> updatePreferences({
    bool? promoNotifications,
    String? locale,
  });
}
