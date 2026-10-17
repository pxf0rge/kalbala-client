import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';

abstract interface class OrderRepository {
  Future<Either<Failure, List<OrderSummaryEntity>>> getMyOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  });

  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String orderId);

  Future<Either<Failure, List<SellerOrderSummaryEntity>>> getSellerOrders({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  });

  Future<Either<Failure, SellerOrderDetailEntity>> getSellerOrderDetail(String sellerOrderId);

  Future<Either<Failure, void>> updateSellerOrderStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  });
}
