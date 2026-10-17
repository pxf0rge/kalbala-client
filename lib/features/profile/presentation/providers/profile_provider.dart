import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/profile/data/datasources/preferences_remote_datasource.dart';
import 'package:rahmani_project/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rahmani_project/features/profile/data/repositories/preferences_repository_impl.dart';
import 'package:rahmani_project/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/entities/profile_entity.dart';
import 'package:rahmani_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/preferences_repository.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';
import 'package:rahmani_project/features/profile/domain/usecases/address_usecases.dart';
import 'package:rahmani_project/features/profile/domain/usecases/get_profile.dart';
import 'package:rahmani_project/features/profile/domain/usecases/update_profile.dart';
import 'package:rahmani_project/features/profile/domain/usecases/upload_avatar.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ProfileRemoteDataSourceImpl(SupabaseConfig.client);
});

final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return AddressRemoteDataSourceImpl(SupabaseConfig.client);
});

final preferencesRemoteDataSourceProvider = Provider<PreferencesRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return PreferencesRemoteDataSourceImpl(SupabaseConfig.client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredProfileRepository();
  return ProfileRepositoryImpl(
    profileRemote: remote,
    client: SupabaseConfig.client,
  );
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final remote = ref.watch(addressRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredAddressRepository();
  return AddressRepositoryImpl(
    addressRemote: remote,
    client: SupabaseConfig.client,
  );
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final remote = ref.watch(preferencesRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredPreferencesRepository();
  return PreferencesRepositoryImpl(
    remote: remote,
    client: SupabaseConfig.client,
  );
});

final getProfileUseCaseProvider = Provider((ref) => GetProfile(ref.watch(profileRepositoryProvider)));
final updateProfileUseCaseProvider = Provider((ref) => UpdateProfile(ref.watch(profileRepositoryProvider)));
final uploadAvatarUseCaseProvider = Provider((ref) => UploadAvatar(ref.watch(profileRepositoryProvider)));
final getAddressesUseCaseProvider = Provider((ref) => GetAddresses(ref.watch(addressRepositoryProvider)));
final addAddressUseCaseProvider = Provider((ref) => AddAddress(ref.watch(addressRepositoryProvider)));
final updateAddressUseCaseProvider = Provider((ref) => UpdateAddress(ref.watch(addressRepositoryProvider)));
final deleteAddressUseCaseProvider = Provider((ref) => DeleteAddress(ref.watch(addressRepositoryProvider)));
final setDefaultAddressUseCaseProvider = Provider((ref) => SetDefaultAddress(ref.watch(addressRepositoryProvider)));

/// Current user profile for profile screens.
final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileEntity?> {
  @override
  Future<ProfileEntity?> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return null;

    final result = await ref.read(getProfileUseCaseProvider).call();
    return result.fold((_) => null, (profile) => profile);
  }

  Future<bool> updateName(String fullName) async {
    final result = await ref.read(updateProfileUseCaseProvider).call(fullName: fullName);
    return result.fold(
      (_) => false,
      (profile) {
        state = AsyncData(profile);
        ref.invalidate(currentUserProvider);
        return true;
      },
    );
  }

  Future<bool> uploadAvatar({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) async {
    final previousUrl = state.valueOrNull?.avatarUrl;
    final result = await ref.read(uploadAvatarUseCaseProvider).call(
          bytes: bytes,
          fileExtension: fileExtension,
          onProgress: onProgress,
        );
    return result.fold(
      (_) => false,
      (profile) {
        if (previousUrl != null && previousUrl.isNotEmpty) {
          CachedNetworkImage.evictFromCache(previousUrl);
        }
        if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
          CachedNetworkImage.evictFromCache(profile.avatarUrl!);
        }
        state = AsyncData(profile);
        ref.invalidate(currentUserProvider);
        return true;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getProfileUseCaseProvider).call();
      return result.fold((_) => null, (profile) => profile);
    });
  }
}

/// User delivery addresses.
final addressesProvider = AsyncNotifierProvider<AddressesNotifier, List<AddressEntity>>(
  AddressesNotifier.new,
);

class AddressesNotifier extends AsyncNotifier<List<AddressEntity>> {
  @override
  Future<List<AddressEntity>> build() async {
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return [];

    final result = await ref.read(getAddressesUseCaseProvider).call();
    return result.fold((_) => [], (addresses) => addresses);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getAddressesUseCaseProvider).call();
      return result.fold((_) => <AddressEntity>[], (addresses) => addresses);
    });
  }

  /// Returns `null` on success, otherwise a user-facing error message.
  Future<String?> add(AddressInput input) async {
    final result = await ref.read(addAddressUseCaseProvider).call(input);
    return result.fold(
      (failure) => failure.message.isNotEmpty ? failure.message : 'خطا در ذخیره آدرس',
      (address) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([address, ...current]);
        return null;
      },
    );
  }

  /// Returns `null` on success, otherwise a user-facing error message.
  Future<String?> updateAddress(String id, AddressInput input) async {
    final result = await ref.read(updateAddressUseCaseProvider).call(
          addressId: id,
          input: input,
        );
    return result.fold(
      (failure) => failure.message.isNotEmpty ? failure.message : 'خطا در ذخیره آدرس',
      (updated) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([
          for (final item in current)
            if (item.id == id) updated else item,
        ]);
        return null;
      },
    );
  }

  Future<bool> remove(String id) async {
    final result = await ref.read(deleteAddressUseCaseProvider).call(id);
    return result.fold(
      (_) => false,
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(current.where((a) => a.id != id).toList());
        return true;
      },
    );
  }

  Future<bool> setDefault(String id) async {
    final result = await ref.read(setDefaultAddressUseCaseProvider).call(id);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}

/// User notification / locale preferences.
final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferencesEntity?>(
  UserPreferencesNotifier.new,
);

class UserPreferencesNotifier extends AsyncNotifier<UserPreferencesEntity?> {
  @override
  Future<UserPreferencesEntity?> build() async {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.user.id != next.valueOrNull?.user.id) {
        ref.invalidateSelf();
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return null;

    final result = await ref.read(preferencesRepositoryProvider).getPreferences();
    return result.fold((_) => null, (prefs) => prefs);
  }

  Future<bool> setPromoNotifications(bool enabled) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(previous.copyWith(promoNotifications: enabled));
    }

    final result = await ref.read(preferencesRepositoryProvider).updatePreferences(
          promoNotifications: enabled,
        );
    return result.fold(
      (_) {
        if (previous != null) state = AsyncData(previous);
        return false;
      },
      (prefs) {
        state = AsyncData(prefs);
        return true;
      },
    );
  }
}
