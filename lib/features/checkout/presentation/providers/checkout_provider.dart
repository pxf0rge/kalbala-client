import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';
import 'package:rahmani_project/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:rahmani_project/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_entities.dart';
import 'package:rahmani_project/features/checkout/domain/entities/checkout_enums.dart';
import 'package:rahmani_project/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rahmani_project/features/checkout/domain/usecases/checkout_usecases.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/features/shipping/presentation/providers/shipping_provider.dart';

final checkoutRemoteDataSourceProvider = Provider<CheckoutRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return CheckoutRemoteDataSourceImpl(SupabaseConfig.client);
});

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final remote = ref.watch(checkoutRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredCheckoutRepository();
  return CheckoutRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getCheckoutSummaryProvider = Provider((ref) => GetCheckoutSummary());
final placeOrderProvider = Provider((ref) => PlaceOrder(ref.watch(checkoutRepositoryProvider)));

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);

class CheckoutState {
  const CheckoutState({
    this.selectedAddressId,
    this.paymentMethod = CheckoutPaymentMethod.cod,
    this.buyerNote = '',
    this.isPlacingOrder = false,
    this.lastResult,
  });

  final String? selectedAddressId;
  final CheckoutPaymentMethod paymentMethod;
  final String buyerNote;
  final bool isPlacingOrder;
  final PlaceOrderResultEntity? lastResult;

  CheckoutState copyWith({
    String? selectedAddressId,
    CheckoutPaymentMethod? paymentMethod,
    String? buyerNote,
    bool? isPlacingOrder,
    PlaceOrderResultEntity? lastResult,
    bool clearResult = false,
  }) {
    return CheckoutState(
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      buyerNote: buyerNote ?? this.buyerNote,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  CheckoutSummaryEntity summary() {
    final cart = ref.read(cartProvider).valueOrNull;
    final items = cart?.items ?? [];
    final addressId = state.selectedAddressId;
    final shippingPreview = addressId != null
        ? ref.read(checkoutShippingPreviewProvider(addressId)).valueOrNull
        : null;

    return ref.read(getCheckoutSummaryProvider).call(
          items: items,
          shippingPreview: shippingPreview,
        );
  }

  void selectAddress(String addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setBuyerNote(String note) {
    state = state.copyWith(buyerNote: note);
  }

  void initDefaultAddress() {
    if (state.selectedAddressId != null) return;
    final addresses = ref.read(addressesProvider).valueOrNull ?? [];
    if (addresses.isEmpty) return;
    final defaultAddress = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.first;
    state = state.copyWith(selectedAddressId: defaultAddress.id);
  }

  Future<PlaceOrderResultEntity?> submitOrder() async {
    final addressId = state.selectedAddressId;
    if (addressId == null) return null;

    state = state.copyWith(isPlacingOrder: true, clearResult: true);

    final note = state.buyerNote.trim();
    final result = await ref.read(placeOrderProvider).call(
          PlaceOrderInput(
            addressId: addressId,
            paymentMethod: state.paymentMethod,
            buyerNote: note.isEmpty ? null : note,
          ),
        );

    return result.fold(
      (_) {
        state = state.copyWith(isPlacingOrder: false);
        return null;
      },
      (orderResult) {
        state = state.copyWith(isPlacingOrder: false, lastResult: orderResult);
        ref.invalidate(cartProvider);
        if (addressId.isNotEmpty) {
          ref.invalidate(checkoutShippingPreviewProvider(addressId));
        }
        return orderResult;
      },
    );
  }

  void reset() {
    state = const CheckoutState();
  }
}
