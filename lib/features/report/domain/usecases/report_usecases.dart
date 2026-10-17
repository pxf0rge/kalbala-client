import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/domain/repositories/report_repository.dart';

final class SubmitReport {
  const SubmitReport(this._repository);

  final ReportRepository _repository;

  Future<Either<Failure, String>> call(SubmitReportInput input) =>
      _repository.submitReport(input);
}

final class GetMyReports {
  const GetMyReports(this._repository);

  final ReportRepository _repository;

  Future<Either<Failure, List<ReportEntity>>> call() => _repository.getMyReports();
}
