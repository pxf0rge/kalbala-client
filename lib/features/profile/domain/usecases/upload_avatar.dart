import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatar {
  const UploadAvatar(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) {
    return _repository.uploadAvatar(
      bytes: bytes,
      fileExtension: fileExtension,
      onProgress: onProgress,
    );
  }
}
