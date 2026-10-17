import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';

abstract interface class ReportRepository {
  Future<Either<Failure, String>> submitReport(SubmitReportInput input);

  Future<Either<Failure, List<ReportEntity>>> getMyReports();
}
