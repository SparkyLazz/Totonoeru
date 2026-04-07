import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated FAB with a 2-item choice menu.
/// - FAB rotates 45° to × on open
/// - Menu springs in above FAB (scale + fade)
/// - Tap outside → dismiss
/// - lightImpact on open, lightImpact on menu item tap
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
  bool _isOpen = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isOpen = !_isOpen);
  }

  void _close() => setState(() => _isOpen = false);

  void _onAddTask() {
    HapticFeedback.lightImpact();
    _close();
    widget.onAddTask();
  }

  void _onAddTimeBlock() {
    HapticFeedback.lightImpact();
    _close();
    widget.onAddTimeBlock();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // ── Scrim — tap outside to close ─────────────────────────────────
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: Container(color: Colors.transparent),
            ),
          ),

        // ── Choice Menu ───────────────────────────────────────────────────
        if (_isOpen)
          Positioned(
            bottom: 72,
            right: 0,
            child: _FabMenu(
              onAddTask: _onAddTask,
              onAddTimeBlock: _onAddTimeBlock,
              surface: surface,
              onSurface: onSurface,
              accent: accent,
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 220.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 180.ms),
          ),

        // ── FAB ───────────────────────────────────────────────────────────
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0, // 45° = 0.125 turns
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ],
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────

class _FabMenu extends StatelessWidget {
  const _FabMenu({
    required this.onAddTask,
    required this.onAddTimeBlock,
    required this.surface,
    required this.onSurface,
    required this.accent,
  });

  final VoidCallback onAddTask;
  final VoidCallback onAddTimeBlock;
  final Color surface;
  final Color onSurface;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Add Task',
              onTap: onAddTask,
              accent: accent,
              onSurface: onSurface,
            ),
            _MenuItem(
              icon: Icons.crop_square_rounded,
              label: 'Add Time Block',
              onTap: onAddTimeBlock,
              accent: accent,
              onSurface: onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
    required this.onSurface,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
