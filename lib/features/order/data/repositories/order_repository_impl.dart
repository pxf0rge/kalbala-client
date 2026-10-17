import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/order/data/datasources/order_remote_datasource.dart';
import 'package:rahmani_project/features/order/data/models/order_models.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/order/domain/repositories/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final OrderRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, List<OrderSummaryEntity>>> getMyOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchMyOrders(limit: limit, offset: offset);
      return Right(
        data.map((row) => OrderModels.summaryFromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String orderId) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchOrderDetail(orderId);
      return Right(OrderModels.detailFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SellerOrderSummaryEntity>>> getSellerOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchSellerOrders(limit: limit, offset: offset);
      return Right(
        data.map((row) => OrderModels.sellerSummaryFromJson(row as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SellerOrderDetailEntity>> getSellerOrderDetail(
    String sellerOrderId,
  ) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchSellerOrderDetail(sellerOrderId);
      return Right(OrderModels.sellerDetailFromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSellerOrderStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      await _remote.updateSellerOrderStatus(
        sellerOrderId: sellerOrderId,
        newStatus: newStatus,
        trackingNumber: trackingNumber,
        shippingProvider: shippingProvider,
      );
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredOrderRepository implements OrderRepository {
  const UnconfiguredOrderRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, List<OrderSummaryEntity>>> getMyOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String orderId) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, List<SellerOrderSummaryEntity>>> getSellerOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, SellerOrderDetailEntity>> getSellerOrderDetail(
    String sellerOrderId,
  ) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, void>> updateSellerOrderStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  }) async =>
      const Left(AuthFailure(_message));
}
