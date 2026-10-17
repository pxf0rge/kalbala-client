import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/core/services/fcm_service.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:rahmani_project/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';
import 'package:rahmani_project/features/notification/domain/repositories/notification_repository.dart';
import 'package:rahmani_project/features/notification/domain/usecases/notification_usecases.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return NotificationRemoteDataSourceImpl(SupabaseConfig.client);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remote = ref.watch(notificationRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredNotificationRepository();
  return NotificationRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final registerDeviceTokenProvider =
    Provider((ref) => RegisterDeviceToken(ref.watch(notificationRepositoryProvider)));

final getNotificationsProvider =
    Provider((ref) => GetNotifications(ref.watch(notificationRepositoryProvider)));

final getUnreadNotificationCountProvider =
    Provider((ref) => GetUnreadNotificationCount(ref.watch(notificationRepositoryProvider)));

final markNotificationReadProvider =
    Provider((ref) => MarkNotificationRead(ref.watch(notificationRepositoryProvider)));

final markAllNotificationsReadProvider =
    Provider((ref) => MarkAllNotificationsRead(ref.watch(notificationRepositoryProvider)));

final removeDeviceTokenProvider =
    Provider((ref) => RemoveDeviceToken(ref.watch(notificationRepositoryProvider)));

/// Selected notification type filter (`null` = all).
final notificationTypeFilterProvider = StateProvider<NotificationType?>((ref) => null);

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, PaginatedListPage<NotificationEntity>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<PaginatedListPage<NotificationEntity>> {
  @override
  Future<PaginatedListPage<NotificationEntity>> build() {
    ref.watch(notificationTypeFilterProvider);
    return _fetchPage(offset: 0);
  }

  String? get _typeFilter => ref.read(notificationTypeFilterProvider)?.dbValue;

  Future<PaginatedListPage<NotificationEntity>> _fetchPage({required int offset}) async {
    final result = await ref.read(getNotificationsProvider).call(
          limit: PaginatedListPage.pageSize,
          offset: offset,
          type: _typeFilter,
        );
    final notifications = result.fold((_) => <NotificationEntity>[], (items) => items);
    return PaginatedListPage(
      items: notifications,
      hasMore: hasMoreItems(fetchedCount: notifications.length),
      offset: offset + notifications.length,
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

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.read(getUnreadNotificationCountProvider).call();
  return result.fold((_) => 0, (count) => count);
});

/// Keeps unread badge / notification list fresh when DB rows change.
final notificationRealtimeSyncProvider = Provider<void>((ref) {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return;

  final sub = ref.watch(notificationRepositoryProvider).watchMyNotifications().listen((_) {
    ref.invalidate(unreadNotificationCountProvider);
    ref.invalidate(notificationsProvider);
  });
  ref.onDispose(sub.cancel);
});

/// Registers the current FCM token when available.
final deviceTokenRegistrationProvider = FutureProvider<void>((ref) async {
  final fcm = FcmService.instance;
  if (!fcm.isAvailable) return;

  final token = fcm.currentToken;
  if (token == null || token.isEmpty) return;

  await ref.read(registerDeviceTokenProvider).call(
        token: token,
        platform: fcm.platform,
      );
});
