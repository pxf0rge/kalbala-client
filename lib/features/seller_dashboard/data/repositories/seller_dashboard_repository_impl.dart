import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/seller_dashboard/data/datasources/seller_dashboard_remote_datasource.dart';
import 'package:rahmani_project/features/seller_dashboard/data/models/seller_dashboard_models.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SellerDashboardRepositoryImpl implements SellerDashboardRepository {
  SellerDashboardRepositoryImpl({
    required SellerDashboardRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final SellerDashboardRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, SellerDashboardStatsEntity>> getDashboardStats(
    String sellerId,
  ) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      if (sellerId.isEmpty) return const Left(ValidationFailure('شناسه فروشنده نامعتبر است.'));

      final data = await _remote.fetchDashboardStats(sellerId);
      return Right(SellerDashboardModels.statsFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredSellerDashboardRepository implements SellerDashboardRepository {
  const UnconfiguredSellerDashboardRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, SellerDashboardStatsEntity>> getDashboardStats(
    String sellerId,
  ) async =>
      const Left(AuthFailure(_message));
}
