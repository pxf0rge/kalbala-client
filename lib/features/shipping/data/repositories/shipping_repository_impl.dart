import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/shipping/data/datasources/shipping_remote_datasource.dart';
import 'package:rahmani_project/features/shipping/data/models/shipping_models.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';
import 'package:rahmani_project/features/shipping/domain/repositories/shipping_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class ShippingRepositoryImpl implements ShippingRepository {
  ShippingRepositoryImpl({
    required ShippingRemoteDataSource remote,
    required SupabaseClient client,
  })  : _remote = remote,
        _client = client;

  final ShippingRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, ShippingPreviewEntity>> getCheckoutShippingPreview(
    String addressId,
  ) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final data = await _remote.fetchCheckoutShippingPreview(addressId);
      return Right(ShippingPreviewModel.fromJson(data));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, double>> calculateShippingCost({
    required String city,
    required int weightGrams,
  }) async {
    try {
      if (_client.auth.currentUser == null) return const Left(AuthFailure());
      final cost = await _remote.calculateShippingCost(city: city, weightGrams: weightGrams);
      return Right(cost);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

final class UnconfiguredShippingRepository implements ShippingRepository {
  const UnconfiguredShippingRepository();

  static const _message = 'Supabase پیکربندی نشده است.';

  @override
  Future<Either<Failure, ShippingPreviewEntity>> getCheckoutShippingPreview(
    String addressId,
  ) async =>
      const Left(AuthFailure(_message));

  @override
  Future<Either<Failure, double>> calculateShippingCost({
    required String city,
    required int weightGrams,
  }) async =>
      const Left(AuthFailure(_message));
}
