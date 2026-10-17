import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/report/data/datasources/report_remote_datasource.dart';
import 'package:rahmani_project/features/report/data/models/report_models.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/domain/repositories/report_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({
    required ReportRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ReportRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, String>> submitReport(SubmitReportInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());

      final validationError = validateReportInput(input);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      final id = await _remote.submitReport(
        targetType: input.targetType.dbValue,
        targetId: input.targetId,
        reason: input.reason.dbValue,
        description: input.description?.trim().isEmpty == true
            ? null
            : input.description?.trim(),
      );
      return Right(id);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getMyReports() async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final rows = await _remote.fetchMyReports();
      return Right(
        rows
            .map((row) => ReportModels.fromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredReportRepository implements ReportRepository {
  const UnconfiguredReportRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, String>> submitReport(SubmitReportInput input) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<ReportEntity>>> getMyReports() async =>
      const Right([]);
}
