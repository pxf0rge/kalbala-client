import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/services/fcm_service.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/notification/domain/entities/notification_entities.dart';
import 'package:rahmani_project/features/notification/presentation/providers/notification_provider.dart';

/// Initializes push notifications, device tokens, and live unread sync.
class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    await FcmService.instance.initialize(
      onNotificationTap: (data) {
        if (!mounted) return;
        final deepLink = resolveNotificationDeepLink(data);
        if (deepLink != null) {
          context.push(deepLink);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (previous, next) {
      final wasLoggedIn = previous?.valueOrNull != null;
      final isLoggedIn = next.valueOrNull != null;

      if (!wasLoggedIn && isLoggedIn) {
        ref.invalidate(deviceTokenRegistrationProvider);
        ref.invalidate(unreadNotificationCountProvider);
      }
    });

    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session != null) {
      ref.watch(deviceTokenRegistrationProvider);
      ref.watch(notificationRealtimeSyncProvider);
      ref.watch(unreadNotificationCountProvider);
    }

    return widget.child;
  }
}
