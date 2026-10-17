import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/order/domain/repositories/order_repository.dart';

class GetMyOrders {
  const GetMyOrders(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, List<OrderSummaryEntity>>> call({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) =>
      _repository.getMyOrders(limit: limit, offset: offset);
}

class GetOrderDetail {
  const GetOrderDetail(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, OrderDetailEntity>> call(String orderId) {
    if (orderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('شناسه سفارش نامعتبر است.')));
    }
    return _repository.getOrderDetail(orderId);
  }
}

class GetSellerOrders {
  const GetSellerOrders(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, List<SellerOrderSummaryEntity>>> call({
    int limit = PaginationConstants.defaultPageSize,
    int offset = 0,
  }) =>
      _repository.getSellerOrders(limit: limit, offset: offset);
}

class GetSellerOrderDetail {
  const GetSellerOrderDetail(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, SellerOrderDetailEntity>> call(String sellerOrderId) {
    if (sellerOrderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('شناسه سفارش نامعتبر است.')));
    }
    return _repository.getSellerOrderDetail(sellerOrderId);
  }
}

class UpdateSellerOrderStatus {
  const UpdateSellerOrderStatus(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, void>> call({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
    String? shippingProvider,
  }) {
    if (newStatus == SellerOrderStatus.shipped &&
        (trackingNumber == null || trackingNumber.trim().isEmpty)) {
      return Future.value(const Left(ValidationFailure('کد رهگیری الزامی است.')));
    }
    return _repository.updateSellerOrderStatus(
      sellerOrderId: sellerOrderId,
      newStatus: newStatus,
      trackingNumber: trackingNumber,
      shippingProvider: shippingProvider,
    );
  }
}

class AddTracking {
  const AddTracking(this._repository);
  final OrderRepository _repository;

  Future<Either<Failure, void>> call({
    required String sellerOrderId,
    required String trackingNumber,
    String? shippingProvider,
  }) {
    if (trackingNumber.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('کد رهگیری الزامی است.')));
    }
    return _repository.updateSellerOrderStatus(
      sellerOrderId: sellerOrderId,
      newStatus: SellerOrderStatus.shipped,
      trackingNumber: trackingNumber.trim(),
      shippingProvider: shippingProvider,
    );
  }
}
