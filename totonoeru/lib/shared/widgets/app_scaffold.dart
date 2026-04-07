import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ── App Scaffold (wraps StatefulShellRoute) ───────────────────────────────────

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact(); // task 1.29 — lightImpact on nav tap
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ── Bottom Nav Bar (task 1.29) ────────────────────────────────────────────────

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final scheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        _navDest(
          context,
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home',
          isSelected: currentIndex == 0,
          accent: accent,
          onSurface: scheme.onSurface,
        ),
        _navDest(
          context,
          icon: Icons.check_circle_outline_rounded,
          activeIcon: Icons.check_circle_rounded,
          label: 'Tasks',
          isSelected: currentIndex == 1,
          accent: accent,
          onSurface: scheme.onSurface,
        ),
        _navDest(
          context,
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today_rounded,
          label: 'Schedule',
          isSelected: currentIndex == 2,
          accent: accent,
          onSurface: scheme.onSurface,
        ),
        _navDest(
          context,
          icon: Icons.timer_outlined,
          activeIcon: Icons.timer_rounded,
          label: 'Focus',
          isSelected: currentIndex == 3,
          accent: accent,
          onSurface: scheme.onSurface,
        ),
        _navDest(
          context,
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
          label: 'Settings',
          isSelected: currentIndex == 4,
          accent: accent,
          onSurface: scheme.onSurface,
        ),
      ],
    );
  }

  NavigationDestination _navDest(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color accent,
    required Color onSurface,
  }) {
    return NavigationDestination(
      icon: Icon(icon, color: isSelected ? accent : onSurface.withOpacity(0.5)),
      selectedIcon: Icon(activeIcon, color: accent),
      label: label,
    );
  }
}
