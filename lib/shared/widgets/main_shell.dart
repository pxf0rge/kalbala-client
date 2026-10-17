import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/theme/theme_mode_provider.dart';
import 'package:rahmani_project/features/cart/presentation/providers/cart_provider.dart';

/// Buyer shell — marketplace bottom navigation with active pill.
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  static const _tabRoutes = [
    RouteNames.home,
    RouteNames.categories,
    RouteNames.cart,
    RouteNames.orders,
    RouteNames.profile,
  ];

  int _selectedIndex(String location) {
    if (location.startsWith(RouteNames.profile)) return 4;
    if (location == RouteNames.orders) return 3;
    if (location == RouteNames.cart) return 2;
    if (location == RouteNames.categories) return 1;
    return 0;
  }

  bool _showBottomNav(String location) {
    return _tabRoutes.any(
      (route) => location == route || location.startsWith('${RouteNames.profile}/'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final showNav = _showBottomNav(location);
    final cartCount = ref.watch(cartItemCountProvider);
    ref.watch(themeModeProvider);
    final selected = _selectedIndex(location);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      extendBody: false,
      bottomNavigationBar: showNav
          ? _RahmaniBottomBar(
              selectedIndex: selected,
              cartCount: cartCount,
              onSelect: (index) => context.go(_tabRoutes[index]),
            )
          : null,
    );
  }
}

class _RahmaniBottomBar extends StatelessWidget {
  const _RahmaniBottomBar({
    required this.selectedIndex,
    required this.cartCount,
    required this.onSelect,
  });

  final int selectedIndex;
  final int cartCount;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.7))),
          color: scheme.surface,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.navHeight,
            child: Row(
              children: [
                _NavItem(
                  index: 0,
                  selected: selectedIndex == 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'خانه',
                  onTap: onSelect,
                ),
                _NavItem(
                  index: 1,
                  selected: selectedIndex == 1,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'جستجو',
                  onTap: onSelect,
                ),
                _NavItem(
                  index: 2,
                  selected: selectedIndex == 2,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'سبد',
                  badge: cartCount,
                  onTap: onSelect,
                ),
                _NavItem(
                  index: 3,
                  selected: selectedIndex == 3,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'سفارش',
                  onTap: onSelect,
                ),
                _NavItem(
                  index: 4,
                  selected: selectedIndex == 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'من',
                  onTap: onSelect,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final int index;
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.inkMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge'),
                  backgroundColor: AppColors.primary,
                  child: Icon(selected ? activeIcon : icon, color: color, size: 22),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 10,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
