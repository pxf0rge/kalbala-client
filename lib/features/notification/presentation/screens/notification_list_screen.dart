import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/models/paginated_list_page.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';
import 'package:rahmani_project/features/notification/presentation/widgets/notification_tile.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// In-app notification center with type filters.
class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen> {
  final _scrollController = ScrollController();

  static const _filterTypes = <NotificationType?>[
    null,
    NotificationType.order,
    NotificationType.orderStatus,
    NotificationType.payment,
    NotificationType.message,
    NotificationType.promotion,
    NotificationType.system,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (shouldLoadMoreFromScroll(
      pixels: _scrollController.position.pixels,
      maxScrollExtent: _scrollController.position.maxScrollExtent,
    )) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final selectedType = ref.watch(notificationTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(context, ref),
            child: const Text('خواندن همه'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filterTypes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = _filterTypes[index];
                final selected = selectedType == type;
                return FilterChip(
                  label: Text(type?.labelFa ?? 'همه'),
                  selected: selected,
                  onSelected: (_) {
                    ref.read(notificationTypeFilterProvider.notifier).state = type;
                  },
                );
              },
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری اعلان‌ها...'),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(notificationsProvider),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'اعلانی ندارید',
                    subtitle: 'اعلان‌های سفارش، پرداخت، پرومو و پیام اینجا نمایش داده می‌شوند.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationsProvider.notifier).refresh();
                    ref.invalidate(unreadNotificationCountProvider);
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: page.items.length + (page.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index >= page.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final notification = page.items[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _openNotification(context, ref, notification),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(markAllNotificationsReadProvider).call();
    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
      },
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    if (!notification.isRead) {
      await ref.read(markNotificationReadProvider).call(notification.id);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    }

    if (!context.mounted) return;

    final deepLink = resolveNotificationDeepLink(notification.data);
    if (deepLink != null) {
      context.push(deepLink);
    }
  }
}