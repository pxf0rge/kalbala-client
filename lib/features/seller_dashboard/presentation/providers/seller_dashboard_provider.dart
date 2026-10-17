import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/seller_dashboard/data/datasources/seller_dashboard_remote_datasource.dart';
import 'package:rahmani_project/features/seller_dashboard/data/repositories/seller_dashboard_repository_impl.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/entities/seller_dashboard_entities.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';
import 'package:rahmani_project/features/seller_dashboard/domain/usecases/seller_dashboard_usecases.dart';

final sellerDashboardRemoteDataSourceProvider =
    Provider<SellerDashboardRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return SellerDashboardRemoteDataSourceImpl(SupabaseConfig.client);
});

final sellerDashboardRepositoryProvider = Provider<SellerDashboardRepository>((ref) {
  final remote = ref.watch(sellerDashboardRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredSellerDashboardRepository();
  return SellerDashboardRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getSellerDashboardStatsProvider =
    Provider((ref) => GetSellerDashboardStats(ref.watch(sellerDashboardRepositoryProvider)));

final sellerDashboardProvider = FutureProvider<SellerDashboardStatsEntity>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) {
    throw Exception('لطفاً وارد حساب کاربری شوید.');
  }

  final result = await ref.read(getSellerDashboardStatsProvider).call(session.user.id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});
