import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:rahmani_project/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';
import 'package:rahmani_project/features/payment/domain/repositories/payment_repository.dart';
import 'package:rahmani_project/features/payment/domain/usecases/payment_usecases.dart';

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return PaymentRemoteDataSourceImpl(SupabaseConfig.client);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remote = ref.watch(paymentRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredPaymentRepository();
  return PaymentRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final initiatePaymentProvider = Provider((ref) => InitiatePayment(ref.watch(paymentRepositoryProvider)));
final getPaymentStatusProvider = Provider((ref) => GetPaymentStatus(ref.watch(paymentRepositoryProvider)));
final retryPaymentProvider = Provider((ref) => RetryPayment(ref.watch(paymentRepositoryProvider)));
final completeSandboxPaymentProvider =
    Provider((ref) => CompleteSandboxPayment(ref.watch(paymentRepositoryProvider)));

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);

class PaymentState {
  const PaymentState({
    this.selectedGateway = PaymentGateway.hesabpay,
    this.isProcessing = false,
    this.lastResult,
    this.errorMessage,
  });

  final PaymentGateway selectedGateway;
  final bool isProcessing;
  final InitiatePaymentResultEntity? lastResult;
  final String? errorMessage;

  PaymentState copyWith({
    PaymentGateway? selectedGateway,
    bool? isProcessing,
    InitiatePaymentResultEntity? lastResult,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return PaymentState(
      selectedGateway: selectedGateway ?? this.selectedGateway,
      isProcessing: isProcessing ?? this.isProcessing,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void selectGateway(PaymentGateway gateway) {
    state = state.copyWith(selectedGateway: gateway, clearError: true);
  }

  Future<InitiatePaymentResultEntity?> startPayment({
    required String orderId,
    String? returnUrl,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true, clearResult: true);

    final result = await ref.read(initiatePaymentProvider).call(
          InitiatePaymentInput(
            orderId: orderId,
            gateway: state.selectedGateway,
            returnUrl: returnUrl,
          ),
        );

    return result.fold(
      (failure) {
        state = state.copyWith(isProcessing: false, errorMessage: failure.message);
        return null;
      },
      (paymentResult) {
        state = state.copyWith(isProcessing: false, lastResult: paymentResult);
        return paymentResult;
      },
    );
  }

  Future<InitiatePaymentResultEntity?> retryPayment({
    required String orderId,
    String? returnUrl,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true, clearResult: true);

    final result = await ref.read(retryPaymentProvider).call(
          orderId: orderId,
          gateway: state.selectedGateway,
          returnUrl: returnUrl,
        );

    return result.fold(
      (failure) {
        state = state.copyWith(isProcessing: false, errorMessage: failure.message);
        return null;
      },
      (paymentResult) {
        state = state.copyWith(isProcessing: false, lastResult: paymentResult);
        return paymentResult;
      },
    );
  }

  void reset() {
    state = const PaymentState();
  }
}

final paymentStatusProvider = FutureProvider.family<PaymentEntity?, String>((ref, paymentId) async {
  final result = await ref.read(getPaymentStatusProvider).call(paymentId);
  return result.fold((_) => null, (payment) => payment);
});
