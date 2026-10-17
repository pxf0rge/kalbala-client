import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ReportRemoteDataSource {
  Future<String> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  });

  Future<List<dynamic>> fetchMyReports();
}

final class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    try {
      final data = await _client.rpc(
        'submit_report',
        params: {
          'p_target_type': targetType,
          'p_target_id': targetId,
          'p_reason': reason,
          'p_description': description,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchMyReports() async {
    try {
      final data = await _client.rpc('get_my_reports');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
