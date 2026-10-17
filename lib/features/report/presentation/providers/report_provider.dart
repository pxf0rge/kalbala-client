import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/report/data/datasources/report_remote_datasource.dart';
import 'package:rahmani_project/features/report/data/repositories/report_repository_impl.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/domain/repositories/report_repository.dart';
import 'package:rahmani_project/features/report/domain/usecases/report_usecases.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ReportRemoteDataSourceImpl(SupabaseConfig.client);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remote = ref.watch(reportRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredReportRepository();
  return ReportRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final submitReportProvider =
    Provider((ref) => SubmitReport(ref.watch(reportRepositoryProvider)));

final getMyReportsProvider =
    Provider((ref) => GetMyReports(ref.watch(reportRepositoryProvider)));

final myReportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final result = await ref.read(getMyReportsProvider).call();
  return result.fold((_) => [], (reports) => reports);
});
