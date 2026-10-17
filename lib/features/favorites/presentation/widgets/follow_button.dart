import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';

/// Toggle follow state for a booth (optimistic + login gate).
class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({
    required this.boothId,
    this.boothSlug,
    this.isOwner = false,
    super.key,
  });

  final String boothId;

  /// When set, updates the public booth follower count after a successful toggle.
  final String? boothSlug;
  final bool isOwner;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool? _optimistic;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isOwner) return const SizedBox.shrink();

    final session = ref.watch(authSessionProvider).valueOrNull;
    final followingAsync = ref.watch(isFollowingProvider(widget.boothId));
    final isFollowing = _optimistic ?? followingAsync.valueOrNull ?? false;

    return OutlinedButton.icon(
      onPressed: _busy
          ? null
          : () async {
              if (session == null) {
                context.push(RouteNames.login);
                return;
              }
              final previous = isFollowing;
              setState(() {
                _optimistic = !previous;
                _busy = true;
              });
              final success = await ref.read(followedBoothsProvider.notifier).toggle(
                    widget.boothId,
                    currentlyFollowing: previous,
                  );
              if (!mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطا در به‌روزرسانی دنبال‌کردن')),
                );
              } else if (widget.boothSlug != null) {
                ref
                    .read(publicBoothProvider(widget.boothSlug!).notifier)
                    .adjustFollowerCount(previous ? -1 : 1);
              }
              setState(() {
                _busy = false;
                if (!success) _optimistic = previous;
              });
            },
      icon: Icon(isFollowing ? Icons.person_remove_outlined : Icons.person_add_outlined),
      label: Text(isFollowing ? 'دنبال می‌کنید' : 'دنبال کردن'),
    );
  }
}
