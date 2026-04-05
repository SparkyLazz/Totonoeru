import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP FAB
// Decision 3: FAB tapped → compact choice menu (Add task / Add time block).
// FAB rotates 45° to become ×. Menu animates in with scale + fade.
// Tapping anywhere outside dismisses. Same FAB on all screens.
// ─────────────────────────────────────────────────────────────────────────────

class AppFab extends StatefulWidget {
  const AppFab({
    super.key,
    required this.onAddTask,
    required this.onAddTimeBlock,
  });

  final VoidCallback onAddTask;
  final VoidCallback onAddTimeBlock;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotateAnim = Tween<double>(begin: 0, end: math.pi / 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _close() {
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  void _handleAddTask() {
    _close();
    widget.onAddTask();
  }

  void _handleAddTimeBlock() {
    _close();
    widget.onAddTimeBlock();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop tap-to-dismiss
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

        // Choice menu
        Positioned(
          bottom: AppSpacing.fabSize + AppSpacing.md,
          right: 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              alignment: Alignment.bottomRight,
              child: Opacity(opacity: _fadeAnim.value, child: child),
            ),
            child: _FabMenu(
              accentColor: accent.accent,
              onAddTask: _handleAddTask,
              onAddTimeBlock: _handleAddTimeBlock,
            ),
          ),
        ),

        // FAB button
        AnimatedBuilder(
          animation: _rotateAnim,
          builder: (context, child) => Transform.rotate(
            angle: _rotateAnim.value,
            child: child,
          ),
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: accent.accent,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ],
    );
  }
}

// ── CHOICE MENU CARD ─────────────────────────────────────────────────────────

class _FabMenu extends StatelessWidget {
  const _FabMenu({
    required this.accentColor,
    required this.onAddTask,
    required this.onAddTimeBlock,
  });

  final Color accentColor;
  final VoidCallback onAddTask;
  final VoidCallback onAddTimeBlock;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).colorScheme.outline;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuOption(
            icon: Icons.check_box_outlined,
            label: 'Add task',
            sublabel: 'To-do',
            accentColor: accentColor,
            onTap: onAddTask,
            showDivider: true,
          ),
          _MenuOption(
            icon: Icons.calendar_today_outlined,
            label: 'Add time block',
            sublabel: 'Schedule',
            accentColor: accentColor,
            onTap: onAddTimeBlock,
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accentColor,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color accentColor;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.outline;
    final border = Theme.of(context).colorScheme.outline;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyM.copyWith(color: textPrimary),
                  ),
                ),
                Text(
                  sublabel,
                  style: AppTextStyles.bodyS.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: border),
      ],
    );
  }
}
