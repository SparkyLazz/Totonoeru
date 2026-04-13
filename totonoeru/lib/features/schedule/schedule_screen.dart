// lib/features/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_fab.dart';
import '../tasks/add_task_sheet.dart'; // ← ADD
import 'add_time_block_sheet.dart';
import 'hourly_timeline.dart';
import 'week_strip.dart';

export 'schedule_screen.dart' show ScheduleView;

enum ScheduleView { day, week, month }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, this.initialView = ScheduleView.day});
  final ScheduleView initialView;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late ScheduleView _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
  }

  void _openAddBlock([DateTime? initialTime]) {
    final selected = ref.read(selectedDateProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTimeBlockSheet(
        initialDate: selected,
        initialTime: initialTime,
      ),
    );
  }

  void _openAddTask() { // ← ADD
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule',
                          style: AppTypography.displayMedium
                              .copyWith(color: textPrimary),
                        ),
                        Text(
                          'スケジュール',
                          style: AppTypography.jpLight
                              .copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _ViewPill(
                    current: _view,
                    onSelect: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _view = v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const WeekStrip(),

            const SizedBox(height: 4),

            Expanded(
              child: _view == ScheduleView.day
                  ? HourlyTimeline(onTapEmpty: _openAddBlock)
                  : _PlaceholderView(view: _view),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: _openAddTask,       // ← CHANGED from () {}
        onAddTimeBlock: _openAddBlock,
      ),
    );
  }
}

// ── View pill ─────────────────────────────────────────────────────────────────

class _ViewPill extends StatelessWidget {
  const _ViewPill({required this.current, required this.onSelect});
  final ScheduleView current;
  final ValueChanged<ScheduleView> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: scheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ScheduleView.values.map((v) {
          final isSelected = v == current;
          final label = switch (v) {
            ScheduleView.day => 'Day',
            ScheduleView.week => 'Week',
            ScheduleView.month => 'Month',
          };
          return GestureDetector(
            onTap: () => onSelect(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : scheme.onSurface.withOpacity(0.5),
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Week/Month placeholder (built in Week 4) ──────────────────────────────────

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.view});
  final ScheduleView view;

  @override
  Widget build(BuildContext context) {
    final label = view == ScheduleView.week ? 'Week View' : 'Month View';
    final sub = view == ScheduleView.week ? '週間 — Week 4' : '月間 — Week 4';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_view_week_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(label,
              style: AppTypography.headingMedium.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3))),
          Text(sub,
              style: AppTypography.jpLight.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.2))),
        ],
      ),
    );
  }
}