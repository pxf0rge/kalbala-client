import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call({String? fullName}) {
    return _repository.updateProfile(fullName: fullName);
  }
}
