import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/favorites/presentation/providers/favorites_provider.dart';

/// Toggle favorite state for a listing (optimistic + login gate).
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    required this.listingId,
    this.compact = false,
    super.key,
  });

  final String listingId;

  /// Soft circular chip for product-card overlays.
  final bool compact;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool? _optimistic;
  bool _busy = false;

  Future<void> _toggle(bool isFavorited) async {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      context.push(RouteNames.login);
      return;
    }
    final previous = isFavorited;
    setState(() {
      _optimistic = !previous;
      _busy = true;
    });
    final success = await ref.read(favoritesProvider.notifier).toggle(
          widget.listingId,
          currentlyFavorited: previous,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!success) _optimistic = previous;
    });
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در به‌روزرسانی علاقه‌مندی')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritedAsync = ref.watch(isFavoritedProvider(widget.listingId));
    final isFavorited = _optimistic ?? favoritedAsync.valueOrNull ?? false;
    final tooltip =
        isFavorited ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها';

    if (widget.compact) {
      return Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _busy ? null : () => _toggle(isFavorited),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: isFavorited ? const Color(0xFFE11D48) : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: _busy ? null : () => _toggle(isFavorited),
      icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
      color: isFavorited ? Colors.red : null,
    );
  }
}
