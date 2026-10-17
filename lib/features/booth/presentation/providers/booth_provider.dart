import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/booth/data/datasources/booth_remote_datasource.dart';
import 'package:rahmani_project/features/booth/data/repositories/booth_repository_impl.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_entities.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:rahmani_project/features/booth/domain/usecases/booth_usecases.dart';

final boothRemoteDataSourceProvider = Provider<BoothRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return BoothRemoteDataSourceImpl(SupabaseConfig.client);
});

final boothRepositoryProvider = Provider<BoothRepository>((ref) {
  final remote = ref.watch(boothRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredBoothRepository();
  return BoothRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final getVerificationStatusProvider =
    Provider((ref) => GetVerificationStatus(ref.watch(boothRepositoryProvider)));
final submitVerificationProvider =
    Provider((ref) => SubmitVerification(ref.watch(boothRepositoryProvider)));
final applyForBoothProvider =
    Provider((ref) => ApplyForBooth(ref.watch(boothRepositoryProvider)));
final getMyApplicationsProvider =
    Provider((ref) => GetMyApplications(ref.watch(boothRepositoryProvider)));
final getMyBoothsProvider = Provider((ref) => GetMyBooths(ref.watch(boothRepositoryProvider)));
final getBoothProvider = Provider((ref) => GetBooth(ref.watch(boothRepositoryProvider)));
final updateBoothProvider = Provider((ref) => UpdateBooth(ref.watch(boothRepositoryProvider)));
final setBoothActiveProvider =
    Provider((ref) => SetBoothActive(ref.watch(boothRepositoryProvider)));

final verificationProvider = AsyncNotifierProvider<VerificationNotifier, SellerVerificationEntity?>(
  VerificationNotifier.new,
);

class VerificationNotifier extends AsyncNotifier<SellerVerificationEntity?> {
  @override
  Future<SellerVerificationEntity?> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return null;

    final result = await ref.read(getVerificationStatusProvider).call();
    return result.fold((_) => null, (v) => v);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<bool> submit(
    VerificationInput input, {
    void Function(double progress, String message)? onProgress,
  }) async {
    final result = await ref.read(submitVerificationProvider).call(
          input,
          onProgress: onProgress,
        );
    return result.fold(
      (_) => false,
      (verification) {
        state = AsyncData(verification);
        return true;
      },
    );
  }
}

final myApplicationsProvider =
    AsyncNotifierProvider<MyApplicationsNotifier, List<BoothApplicationEntity>>(
  MyApplicationsNotifier.new,
);

class MyApplicationsNotifier extends AsyncNotifier<List<BoothApplicationEntity>> {
  @override
  Future<List<BoothApplicationEntity>> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return [];

    final result = await ref.read(getMyApplicationsProvider).call();
    return result.fold((_) => [], (apps) => apps);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final myBoothsProvider = AsyncNotifierProvider<MyBoothsNotifier, List<BoothEntity>>(
  MyBoothsNotifier.new,
);

class MyBoothsNotifier extends AsyncNotifier<List<BoothEntity>> {
  @override
  Future<List<BoothEntity>> build() async {
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return [];

    final result = await ref.read(getMyBoothsProvider).call();
    return result.fold((_) => [], (booths) => booths);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final boothDetailProvider =
    AsyncNotifierProvider.family<BoothDetailNotifier, BoothEntity?, String>(
  BoothDetailNotifier.new,
);

class BoothDetailNotifier extends FamilyAsyncNotifier<BoothEntity?, String> {
  late String _boothId;

  @override
  Future<BoothEntity?> build(String boothId) async {
    _boothId = boothId;
    final result = await ref.read(getBoothProvider).call(boothId);
    return result.fold((_) => null, (booth) => booth);
  }

  Future<bool> updateBooth(
    BoothUpdateInput input, {
    void Function(double progress, String message)? onProgress,
  }) async {
    final result = await ref.read(updateBoothProvider).call(
          boothId: _boothId,
          input: input,
          onProgress: onProgress,
        );
    return result.fold(
      (_) => false,
      (booth) {
        state = AsyncData(booth);
        ref.invalidate(myBoothsProvider);
        return true;
      },
    );
  }

  Future<bool> setActive(bool active) async {
    final result = await ref.read(setBoothActiveProvider).call(
          boothId: _boothId,
          active: active,
        );
    return result.fold(
      (_) => false,
      (booth) {
        state = AsyncData(booth);
        ref.invalidate(myBoothsProvider);
        return true;
      },
    );
  }
}
