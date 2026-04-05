import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV BAR
// 5 tabs: Home · Tasks · Schedule · Focus · Settings
// Decision 1: tab order locked. Focus is a first-class tab.
// Uses accent color from ThemeExtension — never hardcoded.
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,           label: 'Home',     labelJP: ''),
    _TabItem(icon: Icons.check_box_outlined,  activeIcon: Icons.check_box_rounded,      label: 'Tasks',    labelJP: 'タスク'),
    _TabItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Schedule', labelJP: '予定'),
    _TabItem(icon: Icons.timer_outlined,      activeIcon: Icons.timer_rounded,          label: 'Focus',    labelJP: '集中'),
    _TabItem(icon: Icons.settings_outlined,   activeIcon: Icons.settings_rounded,       label: 'Settings', labelJP: ''),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavTabItem(
                  tab: tab,
                  isActive: isActive,
                  accentColor: accent.accent,
                  inactiveColor: isDark
                      ? const Color(0xFF6B6B66)
                      : const Color(0xFF9E9E99),
                  onTap: () {
                    HapticFeedback.lightImpact(); // Decision 9
                    onTap(i);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.tab,
    required this.isActive,
    required this.accentColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isActive;
  final Color accentColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? tab.activeIcon : tab.icon,
              key: ValueKey(isActive),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tab.label,
            style: AppTextStyles.labelXS.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.labelJP,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String labelJP;
}
