import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/shipping/data/datasources/shipping_remote_datasource.dart';
import 'package:rahmani_project/features/shipping/data/repositories/shipping_repository_impl.dart';
import 'package:rahmani_project/features/shipping/domain/entities/shipping_entities.dart';
import 'package:rahmani_project/features/shipping/domain/repositories/shipping_repository.dart';
import 'package:rahmani_project/features/shipping/domain/usecases/shipping_usecases.dart';

final shippingRemoteDataSourceProvider = Provider<ShippingRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ShippingRemoteDataSourceImpl(SupabaseConfig.client);
});

final shippingRepositoryProvider = Provider<ShippingRepository>((ref) {
  final remote = ref.watch(shippingRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredShippingRepository();
  return ShippingRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getCheckoutShippingPreviewProvider =
    Provider((ref) => GetCheckoutShippingPreview(ref.watch(shippingRepositoryProvider)));

final calculateShippingCostProvider =
    Provider((ref) => CalculateShippingCost(ref.watch(shippingRepositoryProvider)));

final checkoutShippingPreviewProvider =
    FutureProvider.family<ShippingPreviewEntity?, String>((ref, addressId) async {
  if (addressId.isEmpty) return null;
  final result = await ref.read(getCheckoutShippingPreviewProvider).call(addressId);
  return result.fold((_) => null, (preview) => preview);
});
