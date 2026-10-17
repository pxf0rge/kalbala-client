import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';

abstract interface class SellerDashboardRepository {
  Future<Either<Failure, SellerDashboardStatsEntity>> getDashboardStats(String sellerId);
}
