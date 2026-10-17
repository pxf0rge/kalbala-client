import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';

final class GetSellerDashboardStats {
  const GetSellerDashboardStats(this._repository);

  final SellerDashboardRepository _repository;

  Future<Either<Failure, SellerDashboardStatsEntity>> call(String sellerId) =>
      _repository.getDashboardStats(sellerId);
}
