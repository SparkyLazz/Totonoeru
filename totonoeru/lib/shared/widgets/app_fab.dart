// lib/shared/widgets/app_fab.dart
//
// Animated FAB with a 2-item choice menu.
// Fix: uses OverlayPortal so the menu + scrim render at screen level,
// not clipped inside the FAB's own Stack.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class _AppFabState extends State<AppFab> {
  final OverlayPortalController _overlayCtrl = OverlayPortalController();
  bool _isOpen = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _overlayCtrl.show();
      } else {
        _overlayCtrl.hide();
      }
    });
  }

  void _close() {
    setState(() => _isOpen = false);
    _overlayCtrl.hide();
  }

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

    return OverlayPortal(
      controller: _overlayCtrl,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            // ── Full-screen scrim ──────────────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // ── Menu — positioned above FAB bottom-right ───────────────
            Positioned(
              bottom: 88, // above FAB (56px) + margin
              right: 16,
              child: _FabMenu(
                onAddTask: _onAddTask,
                onAddTimeBlock: _onAddTimeBlock,
                surface: surface,
                onSurface: onSurface,
                accent: accent,
              )
                  .animate()
                  .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: 200.ms,
                curve: Curves.easeOutBack,
                alignment: Alignment.bottomRight,
              )
                  .fadeIn(duration: 160.ms),
            ),
          ],
        );
      },
      child: FloatingActionButton(
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
    );
  }
}

// ── Menu card ─────────────────────────────────────────────────────────────────

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