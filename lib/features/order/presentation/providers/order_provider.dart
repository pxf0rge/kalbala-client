import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/order/data/datasources/order_remote_datasource.dart';
import 'package:rahmani_project/features/order/data/repositories/order_repository_impl.dart';
import 'package:rahmani_project/features/order/domain/entities/order_entities.dart';
import 'package:rahmani_project/features/order/domain/entities/order_enums.dart';
import 'package:rahmani_project/features/order/domain/repositories/order_repository.dart';
import 'package:rahmani_project/features/order/domain/usecases/order_usecases.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return OrderRemoteDataSourceImpl(SupabaseConfig.client);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remote = ref.watch(orderRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredOrderRepository();
  return OrderRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getMyOrdersProvider = Provider((ref) => GetMyOrders(ref.watch(orderRepositoryProvider)));
final getOrderDetailProvider = Provider((ref) => GetOrderDetail(ref.watch(orderRepositoryProvider)));
final getSellerOrdersProvider = Provider((ref) => GetSellerOrders(ref.watch(orderRepositoryProvider)));
final getSellerOrderDetailProvider =
    Provider((ref) => GetSellerOrderDetail(ref.watch(orderRepositoryProvider)));
final updateSellerOrderStatusProvider =
    Provider((ref) => UpdateSellerOrderStatus(ref.watch(orderRepositoryProvider)));
final addTrackingProvider = Provider((ref) => AddTracking(ref.watch(orderRepositoryProvider)));

final myOrdersProvider =
    AsyncNotifierProvider<MyOrdersNotifier, PaginatedListPage<OrderSummaryEntity>>(
  MyOrdersNotifier.new,
);

class MyOrdersNotifier extends AsyncNotifier<PaginatedListPage<OrderSummaryEntity>> {
  @override
  Future<PaginatedListPage<OrderSummaryEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    if (ref.watch(authSessionProvider).valueOrNull == null) {
      return const PaginatedListPage(items: [], hasMore: false, offset: 0);
    }

    return _fetchPage(offset: 0);
  }

  Future<PaginatedListPage<OrderSummaryEntity>> _fetchPage({required int offset}) async {
    final result = await ref.read(getMyOrdersProvider).call(
          limit: PaginatedListPage.pageSize,
          offset: offset,
        );
    final orders = result.fold((_) => <OrderSummaryEntity>[], (items) => items);
    return PaginatedListPage(
      items: orders,
      hasMore: hasMoreItems(fetchedCount: orders.length),
      offset: offset + orders.length,
    );
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = await _fetchPage(offset: current.offset);
    state = AsyncData(
      PaginatedListPage(
        items: [...current.items, ...nextPage.items],
        hasMore: nextPage.hasMore,
        offset: nextPage.offset,
      ),
    );
  }
}

final orderDetailProvider =
    FutureProvider.family<OrderDetailEntity?, String>((ref, orderId) async {
  final result = await ref.read(getOrderDetailProvider).call(orderId);
  return result.fold((_) => null, (detail) => detail);
});

final sellerOrdersProvider =
    AsyncNotifierProvider<SellerOrdersNotifier, PaginatedListPage<SellerOrderSummaryEntity>>(
  SellerOrdersNotifier.new,
);

class SellerOrdersNotifier extends AsyncNotifier<PaginatedListPage<SellerOrderSummaryEntity>> {
  @override
  Future<PaginatedListPage<SellerOrderSummaryEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    if (ref.watch(authSessionProvider).valueOrNull == null) {
      return const PaginatedListPage(items: [], hasMore: false, offset: 0);
    }

    return _fetchPage(offset: 0);
  }

  Future<PaginatedListPage<SellerOrderSummaryEntity>> _fetchPage({required int offset}) async {
    final result = await ref.read(getSellerOrdersProvider).call(
          limit: PaginatedListPage.pageSize,
          offset: offset,
        );
    final orders = result.fold((_) => <SellerOrderSummaryEntity>[], (items) => items);
    return PaginatedListPage(
      items: orders,
      hasMore: hasMoreItems(fetchedCount: orders.length),
      offset: offset + orders.length,
    );
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = await _fetchPage(offset: current.offset);
    state = AsyncData(
      PaginatedListPage(
        items: [...current.items, ...nextPage.items],
        hasMore: nextPage.hasMore,
        offset: nextPage.offset,
      ),
    );
  }

  Future<bool> advanceStatus({
    required String sellerOrderId,
    required SellerOrderStatus newStatus,
    String? trackingNumber,
  }) async {
    final result = await ref.read(updateSellerOrderStatusProvider).call(
          sellerOrderId: sellerOrderId,
          newStatus: newStatus,
          trackingNumber: trackingNumber,
        );
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidate(sellerOrderDetailProvider(sellerOrderId));
        ref.invalidateSelf();
        return true;
      },
    );
  }
}

final sellerOrderDetailProvider =
    FutureProvider.family<SellerOrderDetailEntity?, String>((ref, sellerOrderId) async {
  final result = await ref.read(getSellerOrderDetailProvider).call(sellerOrderId);
  return result.fold((_) => null, (detail) => detail);
});
