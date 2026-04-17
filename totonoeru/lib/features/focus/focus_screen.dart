// lib/features/focus/focus_screen.dart
// Task 5.09 — Full Focus / Pomodoro screen
//
// FIX (line 469): Container borderRadius assigned BorderRadius where double expected.
//   Root cause: used AppRadius.card (a double constant) inside BorderRadius.circular()
//   — that IS correct, but the error appears when you accidentally pass
//   the BorderRadius object to a property expecting a plain double.
//   All BorderRadius usages below use BorderRadius.circular(12) or explicit values.
// FIX (line 613): Same pattern — _SessionLogItem decoration fixed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/focus_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/focus_session.dart';
import '../../shared/widgets/app_toast.dart';
import 'widgets/focus_ring.dart';
import 'widgets/task_picker_sheet.dart';

// ── Radius constants (plain doubles, avoids any AppRadius confusion) ──
const double _kCardRadius = 12.0;
const double _kIconRadius = 8.0;
const double _kChipRadius = 10.0;
const double _kPillRadius = 12.0;
const double _kCircleRadius = 999.0;

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // ── Mode button ───────────────────────────────────────────────
  Widget _modeButton(
      BuildContext context,
      WidgetRef ref,
      FocusMode mode,
      String label,
      IconData icon,
      bool isActive,
      ) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(focusProvider.notifier).setMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(_kChipRadius),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 12,
                color: isActive
                    ? cs.onSurface
                    : cs.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? cs.onSurface
                      : cs.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Session dot ───────────────────────────────────────────────
  Widget _sessionDot(int index, int completed, bool active) {
    final done = index < completed;
    final current = index == completed && active;
    final color = AppColors.statusDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || current ? color : Colors.transparent,
        border: Border.all(
          color: done || current ? color : Colors.black.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: current
            ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
    );
  }

  // ── Control button ────────────────────────────────────────────
  Widget _ctrlButton(
      IconData icon,
      VoidCallback onTap,
      BuildContext context,
      ) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surface,
          border: Border.all(color: cs.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.6)),
      ),
    );
  }

  // ── Small icon button ─────────────────────────────────────────
  Widget _iconButton(
      IconData icon,
      VoidCallback onTap,
      BuildContext context,
      ) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surface,
          border: Border.all(color: cs.outline.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 15, color: cs.onSurface.withOpacity(0.55)),
      ),
    );
  }

  void _showTaskPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskPickerSheet(
        onTaskSelected: (task) =>
            ref.read(focusProvider.notifier).linkTask(task),
        onClear: () => ref.read(focusProvider.notifier).unlinkTask(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(focusProvider);
    final notifier = ref.read(focusProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final accent = AppColors.accentTeal;
    final ringColor = focus.isBreak ? AppColors.priorityMedium : accent;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                0,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus',
                        style: AppTypography.headingLarge
                            .copyWith(color: cs.onBackground),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '集中',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onBackground.withOpacity(0.3),
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _iconButton(
                    Icons.history_rounded,
                        () => context.push('/focus/sessions'),
                    context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Mode pill ──────────────────────────────────────
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(_kPillRadius),
                ),
                child: Row(
                  children: [
                    _modeButton(context, ref, FocusMode.pomodoro,
                        'Pomodoro', Icons.timer_outlined,
                        focus.mode == FocusMode.pomodoro),
                    _modeButton(context, ref, FocusMode.shortFocus,
                        'Short', Icons.bolt_rounded,
                        focus.mode == FocusMode.shortFocus),
                    _modeButton(context, ref, FocusMode.deepWork,
                        'Deep', Icons.lens_blur_rounded,
                        focus.mode == FocusMode.deepWork),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Linked task card ───────────────────────────────
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: _LinkedTaskCard(
                linkedTask: focus.linkedTask?.title,
                onTap: () => _showTaskPicker(context, ref),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // ── Ring + timer ───────────────────────────────────
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // glow
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (_, __) => Opacity(
                        opacity: focus.isActive
                            ? _glowAnimation.value * 0.7
                            : 0.35,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ringColor.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ),
                    // progress ring
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: focus.progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (_, value, __) => CustomPaint(
                        size: const Size(220, 220),
                        painter: FocusRingPainter(
                          progress: value,
                          isBreak: focus.isBreak,
                          accentColor: accent,
                          trackColor:
                          cs.surfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ),
                    // inner labels
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          focus.phaseLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: cs.onBackground.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          focus.formattedTime,
                          // AppTypography.timerDisplay is DMMono w500;
                          // we override size to 48 here (64 reserved for fullscreen)
                          style: AppTypography.timerDisplay.copyWith(
                            color: cs.onBackground,
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          focus.sessionLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onBackground.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Session dots (Pomodoro only) ───────────────────
            if (focus.mode == FocusMode.pomodoro) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(focus.sessionsTarget, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _sessionDot(
                        i, focus.sessionsCompleted, focus.isActive),
                  );
                }),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // ── Controls ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ctrlButton(Icons.replay_rounded, () {
                  HapticFeedback.lightImpact();
                  notifier.reset();
                  AppToast.show(context, 'Timer reset');
                }, context),
                const SizedBox(width: AppSpacing.base),

                // Big play / pause button
                GestureDetector(
                  onTap: notifier.startOrPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ringColor,
                      boxShadow: [
                        BoxShadow(
                          color: ringColor.withOpacity(0.35),
                          blurRadius: focus.isActive ? 24 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      focus.isActive
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.base),
                _ctrlButton(Icons.skip_next_rounded, () {
                  HapticFeedback.lightImpact();
                  notifier.skip();
                  AppToast.show(context, 'Session skipped');
                }, context),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Session log ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base),
              child: _SessionLog(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ── Linked task card ──────────────────────────────────────────────
class _LinkedTaskCard extends StatelessWidget {
  const _LinkedTaskCard({this.linkedTask, required this.onTap});

  final String? linkedTask;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasTask = linkedTask != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(_kCardRadius), // ✅ double → BorderRadius
          border: Border.all(color: cs.outline.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.priorityLow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(_kIconRadius),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 15,
                color: AppColors.priorityLow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LINKED TASK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                      color: cs.onSurface.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    hasTask ? linkedTask! : 'Tap to select a task…',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: hasTask
                          ? cs.onSurface
                          : cs.onSurface.withOpacity(0.35),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: cs.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session log section ───────────────────────────────────────────
class _SessionLog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(todaySessionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TODAY'S SESSIONS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: cs.onBackground.withOpacity(0.35),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) return _emptyLog(cs);
            return Column(
              children: sessions
                  .take(5)
                  .map((s) => _SessionLogItem(session: s))
                  .toList(),
            );
          },
          loading: () => const SizedBox(height: 48),
          error: (_, __) => _emptyLog(cs),
        ),
      ],
    );
  }

  Widget _emptyLog(ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        'No sessions yet today',
        style: TextStyle(
            fontSize: 13, color: cs.onBackground.withOpacity(0.3)),
      ),
    ),
  );
}

class _SessionLogItem extends StatelessWidget {
  const _SessionLogItem({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mins = session.durationSeconds ~/ 60;
    final secs = session.durationSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final tod = session.startedAt != null
        ? TimeOfDay.fromDateTime(session.startedAt!)
        : null;
    final formatted = tod != null
        ? '${tod.hourOfPeriod}:${tod.minute.toString().padLeft(2, '0')} ${tod.period.name.toUpperCase()}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(_kCardRadius), // ✅ correct
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: session.completed
                  ? AppColors.accentTeal.withOpacity(0.12)
                  : AppColors.priorityMedium.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(_kIconRadius), // ✅ correct
            ),
            child: Icon(
              session.completed
                  ? Icons.check_circle_outline_rounded
                  : Icons.coffee_rounded,
              size: 15,
              color: session.completed
                  ? AppColors.accentTeal
                  : AppColors.priorityMedium,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.completed ? 'Work session' : 'Short break',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${session.completed ? 'Completed' : 'Break'} · $formatted',
                  style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'DMMono',
              color: cs.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}