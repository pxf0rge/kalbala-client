import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:rahmani_project/features/checkout/data/models/checkout_models.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final CheckoutRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, PlaceOrderResultEntity>> placeOrder(PlaceOrderInput input) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.placeOrder(
        addressId: input.addressId,
        paymentMethod: input.paymentMethod,
        cartId: input.cartId,
        buyerNote: input.buyerNote,
      );
      return Right(PlaceOrderResultModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredCheckoutRepository implements CheckoutRepository {
  const UnconfiguredCheckoutRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, PlaceOrderResultEntity>> placeOrder(PlaceOrderInput input) async =>
      const Left(AuthFailure(_message));
}
