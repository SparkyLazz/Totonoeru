// lib/features/schedule/schedule_screen.dart
//
// Updated Week 4: replaces _PlaceholderView stubs with real views

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_fab.dart';
import '../tasks/add_task_sheet.dart';
import 'add_time_block_sheet.dart';
import 'hourly_timeline.dart';
import 'month_calendar.dart';
import 'week_strip.dart';
import 'weekly_overview.dart';

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

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  // Called when week/month view taps a day → switch to day view
  void _switchToDay(DateTime day) {
    setState(() => _view = ScheduleView.day);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    return Scaffold(
      backgroundColor: scheme.surface,
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

            // WeekStrip is shown for day view only
            if (_view == ScheduleView.day) ...[
              const WeekStrip(),
              const SizedBox(height: 4),
            ],

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: _openAddTask,
        onAddTimeBlock: _openAddBlock,
      ),
    );
  }

  Widget _buildBody() {
    return switch (_view) {
      ScheduleView.day =>
          HourlyTimeline(onTapEmpty: _openAddBlock),
      ScheduleView.week =>
          WeeklyOverview(onDayTapped: _switchToDay),
      ScheduleView.month =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: MonthCalendar(onDayTapped: _switchToDay),
          ),
    };
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