import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rahmani_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rahmani_project/features/auth/domain/entities/user_entity.dart';
import 'package:rahmani_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:rahmani_project/features/auth/domain/usecases/get_current_user.dart';
import 'package:rahmani_project/features/auth/domain/usecases/send_otp.dart';
import 'package:rahmani_project/features/auth/domain/usecases/sign_out.dart';
import 'package:rahmani_project/features/auth/domain/usecases/verify_otp.dart';
import 'package:rahmani_project/core/errors/exceptions.dart' as errors;
import 'package:supabase_flutter/supabase_flutter.dart';

/// High-level auth status for routing.
enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  blocked,
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return AuthRemoteDataSourceImpl(SupabaseConfig.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredAuthRepository();
  return AuthRepositoryImpl(remote);
});

final sendOtpProvider = Provider((ref) => SendOtp(ref.watch(authRepositoryProvider)));
final verifyOtpProvider = Provider((ref) => VerifyOtp(ref.watch(authRepositoryProvider)));
final signOutProvider = Provider((ref) => SignOut(ref.watch(authRepositoryProvider)));
final getCurrentUserProvider = Provider((ref) => GetCurrentUser(ref.watch(authRepositoryProvider)));

/// Supabase auth session stream.
final authSessionProvider = StreamProvider<Session?>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  if (remote == null) {
    return Stream<Session?>.value(null);
  }

  return remote.authStateChanges.map((event) => event.session);
});

/// Current user profile (fetched when session exists).
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return null;

  ref.listen(authSessionProvider, (previous, next) {
    if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
      ref.invalidateSelf();
    }
  });

  final result = await ref.watch(getCurrentUserProvider).call();
  return result.fold((_) => null, (user) => user);
});

/// Derived auth status for go_router redirects.
final authStatusProvider = Provider<AuthStatus>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);

  if (sessionAsync.isLoading && !sessionAsync.hasValue) {
    return AuthStatus.unknown;
  }

  final session = sessionAsync.valueOrNull;
  if (session == null) {
    return AuthStatus.unauthenticated;
  }

  final profileAsync = ref.watch(currentUserProvider);
  if (profileAsync.isLoading && !profileAsync.hasValue) {
    return AuthStatus.unknown;
  }

  final profile = profileAsync.valueOrNull;
  if (profile?.isBlocked == true) {
    return AuthStatus.blocked;
  }

  return AuthStatus.authenticated;
});

/// Notifies go_router when auth state changes.
final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();

  ref.listen(authStatusProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return notifier;
});

final class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Phone OTP send action state.
final sendOtpActionProvider = AsyncNotifierProvider<SendOtpNotifier, void>(
  SendOtpNotifier.new,
);

class SendOtpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> send(String phoneInput) async {
    state = const AsyncLoading();
    final result = await ref.read(sendOtpProvider).call(phoneInput);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

/// OTP verification action state.
final verifyOtpActionProvider = AsyncNotifierProvider<VerifyOtpNotifier, UserEntity?>(
  VerifyOtpNotifier.new,
);

class VerifyOtpNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async => null;

  Future<bool> verify({required String phone, required String otp}) async {
    state = const AsyncLoading();
    final result = await ref.read(verifyOtpProvider).call(phone: phone, otp: otp);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncData(user);
        return true;
      },
    );
  }
}

/// DEV-only direct login action (no SMS OTP). Active only when a
/// `DEV_LOGIN_KEY` is configured outside production builds.
final devLoginActionProvider = AsyncNotifierProvider<DevLoginNotifier, UserEntity?>(
  DevLoginNotifier.new,
);

class DevLoginNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async => null;

  Future<bool> devLogin({required String phone}) async {
    final remote = ref.read(authRemoteDataSourceProvider);
    if (remote == null) {
      state = AsyncError(
        'Supabase پیکربندی نشده است. فایل .env را تنظیم کنید.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      final user = await remote.devSignIn(phone: phone);
      state = AsyncData(user.toEntity());
      return true;
    } on errors.AppException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError('ورود مستقیم ناموفق بود: $e', StackTrace.current);
      return false;
    }
  }
}

/// Sign-out action.
final signOutActionProvider = AsyncNotifierProvider<SignOutNotifier, void>(
  SignOutNotifier.new,
);

class SignOutNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutProvider).call();
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

/// Request OTP for changing the authenticated user's phone.
final requestPhoneChangeActionProvider =
    AsyncNotifierProvider<RequestPhoneChangeNotifier, String?>(
  RequestPhoneChangeNotifier.new,
);

class RequestPhoneChangeNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<bool> request(String newPhone) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).requestPhoneChange(newPhone);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (otp) {
        state = AsyncData(otp);
        return true;
      },
    );
  }
}

/// Confirm phone-change OTP.
final confirmPhoneChangeActionProvider =
    AsyncNotifierProvider<ConfirmPhoneChangeNotifier, UserEntity?>(
  ConfirmPhoneChangeNotifier.new,
);

class ConfirmPhoneChangeNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async => null;

  Future<bool> confirm({required String newPhone, required String otp}) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).confirmPhoneChange(
          newPhone: newPhone,
          otp: otp,
        );
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncData(user);
        ref.invalidate(currentUserProvider);
        return true;
      },
    );
  }
}
