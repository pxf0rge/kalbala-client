import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/booth/data/datasources/booth_remote_datasource.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class BoothRepositoryImpl implements BoothRepository {
  BoothRepositoryImpl({
    required BoothRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final BoothRemoteDataSource _remote;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, SellerVerificationEntity?>> getVerificationStatus() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final model = await _remote.fetchVerification(userId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SellerVerificationEntity>> submitVerification(
    VerificationInput input, {
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      report(0.15, 'در حال آپلود عکس تذکره…');
      final photoUrl = await _remote.uploadVerificationPhoto(
        userId: userId,
        bytes: input.photoBytes,
        extension: input.photoExtension,
      );

      report(0.7, 'در حال ثبت درخواست…');
      final model = await _remote.upsertVerification(
        userId: userId,
        photoUrl: photoUrl,
        fullName: input.fullName,
        idNumber: input.idNumber,
        phone: input.phone,
      );
      report(1, 'ارسال شد');
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BoothApplicationEntity>> applyForBooth(
    BoothApplicationInput input, {
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      String? logoUrl = input.logoUrl;
      String? coverUrl = input.coverUrl;
      final hasLogo = input.logoBytes != null;
      final hasCover = input.coverBytes != null;
      final uploadSteps = (hasLogo ? 1 : 0) + (hasCover ? 1 : 0);
      var completedUploads = 0;

      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      if (hasLogo) {
        report(0.05, 'در حال آپلود لوگو…');
        logoUrl = await _remote.uploadApplicationAsset(
          userId: userId,
          bytes: input.logoBytes!,
          extension: input.logoExtension ?? 'jpg',
          assetType: 'logo',
        );
        completedUploads++;
        report(
          uploadSteps == 0 ? 0.7 : (completedUploads / (uploadSteps + 1)),
          'لوگو آپلود شد',
        );
      }
      if (hasCover) {
        final base = uploadSteps == 0
            ? 0.4
            : completedUploads / (uploadSteps + 1);
        report(base.clamp(0.05, 0.85), 'در حال آپلود کاور…');
        coverUrl = await _remote.uploadApplicationAsset(
          userId: userId,
          bytes: input.coverBytes!,
          extension: input.coverExtension ?? 'jpg',
          assetType: 'cover',
        );
        completedUploads++;
        report(
          uploadSteps == 0 ? 0.85 : (completedUploads / (uploadSteps + 1)),
          'کاور آپلود شد',
        );
      }

      report(
        uploadSteps == 0 ? 0.5 : (uploadSteps / (uploadSteps + 1)),
        'در حال ثبت درخواست…',
      );
      final model = await _remote.createApplication(
        userId: userId,
        input: BoothApplicationInput(
          boothName: input.boothName,
          slug: input.slug,
          ownershipType: input.ownershipType,
          description: input.description,
          categoryId: input.categoryId,
          phone: input.phone,
          address: input.address,
          city: input.city,
          province: input.province,
          businessHours: input.businessHours,
          logoUrl: logoUrl,
          coverUrl: coverUrl,
        ),
      );
      report(1, 'درخواست ثبت شد');
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BoothApplicationEntity>>> getMyApplications() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final models = await _remote.fetchApplications(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BoothEntity>>> getMyBooths() async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());
      final models = await _remote.fetchBoothsByOwner(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BoothEntity>> getBooth(String boothId) async {
    try {
      final model = await _remote.fetchBooth(boothId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BoothEntity>> updateBooth({
    required String boothId,
    required BoothUpdateInput input,
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return const Left(AuthFailure());

      final hasLogo = input.logoBytes != null;
      final hasCover = input.coverBytes != null;
      final uploadSteps = (hasLogo ? 1 : 0) + (hasCover ? 1 : 0);
      var completedUploads = 0;

      void report(double progress, String message) =>
          onProgress?.call(progress.clamp(0.0, 1.0), message);

      String? logoUrl;
      if (hasLogo) {
        report(0.05, 'در حال آپلود لوگو…');
        logoUrl = await _remote.uploadBoothAsset(
          boothId: boothId,
          bytes: input.logoBytes!,
          extension: input.logoExtension ?? 'jpg',
          assetType: 'logo',
        );
        completedUploads++;
        report(
          uploadSteps == 0 ? 0.7 : (completedUploads / (uploadSteps + 1)),
          'لوگو آپلود شد',
        );
      }

      String? coverUrl;
      if (hasCover) {
        final base = uploadSteps == 0
            ? 0.4
            : completedUploads / (uploadSteps + 1);
        report(base.clamp(0.05, 0.85), 'در حال آپلود کاور…');
        coverUrl = await _remote.uploadBoothAsset(
          boothId: boothId,
          bytes: input.coverBytes!,
          extension: input.coverExtension ?? 'jpg',
          assetType: 'cover',
        );
        completedUploads++;
        report(
          uploadSteps == 0 ? 0.85 : (completedUploads / (uploadSteps + 1)),
          'کاور آپلود شد',
        );
      }

      final updates = <String, dynamic>{
        if (input.name != null) 'name': input.name,
        if (input.description != null) 'description': input.description,
        if (input.phone != null) 'phone': input.phone,
        if (input.address != null) 'address': input.address,
        if (input.city != null) 'city': input.city,
        if (input.province != null) 'province': input.province,
        if (input.categoryId != null) 'category_id': input.categoryId,
        if (input.businessHours != null) 'business_hours': input.businessHours!.toJson(),
        if (input.showPhone != null) 'show_phone': input.showPhone,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (coverUrl != null) 'cover_url': coverUrl,
      };

      if (updates.isEmpty) {
        final current = await _remote.fetchBooth(boothId);
        report(1, 'بدون تغییر');
        return Right(current.toEntity());
      }

      report(
        uploadSteps == 0 ? 0.5 : (uploadSteps / (uploadSteps + 1)),
        'در حال ذخیره فروشگاه…',
      );
      final model = await _remote.updateBooth(boothId: boothId, updates: updates);
      report(1, 'ذخیره شد');
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BoothEntity>> setBoothActive({
    required String boothId,
    required bool active,
  }) async {
    try {
      final model = await _remote.setBoothActive(boothId: boothId, active: active);
      return Right(model.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredBoothRepository implements BoothRepository {
  const UnconfiguredBoothRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, SellerVerificationEntity?>> getVerificationStatus() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, SellerVerificationEntity>> submitVerification(
    VerificationInput input, {
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, BoothApplicationEntity>> applyForBooth(
    BoothApplicationInput input, {
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<BoothApplicationEntity>>> getMyApplications() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<BoothEntity>>> getMyBooths() async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, BoothEntity>> getBooth(String boothId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, BoothEntity>> updateBooth({
    required String boothId,
    required BoothUpdateInput input,
    void Function(double progress, String message)? onProgress,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, BoothEntity>> setBoothActive({
    required String boothId,
    required bool active,
  }) async =>
      const Left(AuthFailure(_message));
}
