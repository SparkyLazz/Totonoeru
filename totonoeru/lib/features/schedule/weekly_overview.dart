// lib/features/schedule/weekly_overview.dart
//
// Tasks 4.01–4.05 — Weekly Overview
// 4.01  WeeklyOverview widget scaffold + prev/next week nav
// 4.02  7-column day grid header (Mon–Sun + day numbers)
// 4.03  Hourly rows with time blocks rendered per column
// 4.04  Week stats chips (done, total blocks, focus mins)
// 4.05  Tap day column → writes selectedDateProvider + switches to day view

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/time_block.dart';
import '../../core/providers/categories_provider.dart';
import 'add_time_block_sheet.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const double _hourHeight = 40.0;   // compact vs day view's 64px
const double _timeColW  = 36.0;
const int    _startHour = 6;       // display 06:00–23:00
const int    _endHour   = 23;
const int    _displayHours = _endHour - _startHour + 1;

// ── WeeklyOverview ─────────────────────────────────────────────────────────────

class WeeklyOverview extends ConsumerStatefulWidget {
  const WeeklyOverview({
    super.key,
    required this.onDayTapped,
  });

  /// Called when the user taps a day column header.
  /// Parent should switch to day view + set selectedDateProvider.
  final ValueChanged<DateTime> onDayTapped;

  @override
  ConsumerState<WeeklyOverview> createState() => _WeeklyOverviewState();
}

class _WeeklyOverviewState extends ConsumerState<WeeklyOverview> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    // Sync initial week to whatever day is selected
    final selected = ref.read(selectedDateProvider);
    _weekStart = _mondayOf(selected);
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  // ── Navigation ──────────────────────────────────────────────────────────

  void _prevWeek() {
    HapticFeedback.lightImpact();
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  }

  void _nextWeek() {
    HapticFeedback.lightImpact();
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  }

  void _goToToday() {
    HapticFeedback.lightImpact();
    setState(() => _weekStart = _mondayOf(DateTime.now()));
  }

  void _tapDay(DateTime day) {
    HapticFeedback.lightImpact();
    ref.read(selectedDateProvider.notifier).state =
        DateTime(day.year, day.month, day.day);
    widget.onDayTapped(day);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.45);

    final rangeAsync = ref.watch(rangeBlocksProvider(
      (from: _weekStart, to: _weekEnd),
    ));
    final catsAsync = ref.watch(categoriesProvider);

    final catMap = <String, Category>{
      for (final c in catsAsync.valueOrNull ?? []) c.uuid: c,
    };

    return Column(
      children: [
        // ── Month navigator (4.01) ─────────────────────────────────────
        _MonthNav(
          weekStart: _weekStart,
          weekEnd: _weekEnd,
          onPrev: _prevWeek,
          onNext: _nextWeek,
          onToday: _goToToday,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          scheme: scheme,
        ),

        const SizedBox(height: 6),

        // ── Stats chips (4.04) ─────────────────────────────────────────
        rangeAsync.when(
          data: (blocks) => _StatsChips(blocks: blocks, scheme: scheme),
          loading: () => const SizedBox(height: 28),
          error: (_, __) => const SizedBox(height: 28),
        ),

        const SizedBox(height: 8),

        // ── 7-column grid (4.02 + 4.03) ───────────────────────────────
        Expanded(
          child: rangeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (blocks) => _WeekGrid(
              weekStart: _weekStart,
              blocks: blocks,
              catMap: catMap,
              scheme: scheme,
              onDayTapped: _tapDay,
              onBlockTapped: (block) => _openBlockSheet(context, block),
            ),
          ),
        ),
      ],
    );
  }

  void _openBlockSheet(BuildContext context, TimeBlock block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTimeBlockSheet(editBlock: block),
    );
  }
}

// ── Month navigator ────────────────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.weekStart,
    required this.weekEnd,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.textPrimary,
    required this.textSecondary,
    required this.scheme,
  });

  final DateTime weekStart, weekEnd;
  final VoidCallback onPrev, onNext, onToday;
  final Color textPrimary, textSecondary;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // e.g. "Apr 7 – Apr 13, 2025"
    final label = _rangeLabel(weekStart, weekEnd);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Today shortcut
          GestureDetector(
            onTap: onToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.primary.withOpacity(0.2)),
              ),
              child: Text(
                'Today',
                style: AppTypography.labelSmall.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ArrowBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          const SizedBox(width: 4),
          _ArrowBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }

  String _rangeLabel(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (start.month == end.month) {
      return '${months[start.month - 1]} ${start.day}–${end.day}, ${end.year}';
    }
    return '${months[start.month - 1]} ${start.day} – ${months[end.month - 1]} ${end.day}, ${end.year}';
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: scheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: scheme.onSurface.withOpacity(0.6)),
      ),
    );
  }
}

// ── Stats chips (4.04) ─────────────────────────────────────────────────────────

class _StatsChips extends StatelessWidget {
  const _StatsChips({required this.blocks, required this.scheme});
  final List<TimeBlock> blocks;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final totalBlocks = blocks.length;
    final totalMins = blocks.fold<int>(
        0, (sum, b) => sum + b.endTime.difference(b.startTime).inMinutes);
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    final timeLabel = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';

    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatChip(
            color: AppColors.statusDone,
            label: 'Blocks',
            value: '$totalBlocks',
          ),
          const SizedBox(width: 8),
          _StatChip(
            color: AppColors.accentBlue,
            label: 'Scheduled',
            value: totalMins > 0 ? timeLabel : '—',
          ),
          const SizedBox(width: 8),
          _StatChip(
            color: AppColors.priorityMedium,
            label: 'Days active',
            value: '${_activeDays(blocks)}',
          ),
        ],
      ),
    );
  }

  int _activeDays(List<TimeBlock> blocks) {
    final days = <String>{};
    for (final b in blocks) {
      days.add('${b.startTime.year}-${b.startTime.month}-${b.startTime.day}');
    }
    return days.length;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 7-column week grid (4.02 + 4.03) ──────────────────────────────────────────

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.weekStart,
    required this.blocks,
    required this.catMap,
    required this.scheme,
    required this.onDayTapped,
    required this.onBlockTapped,
  });

  final DateTime weekStart;
  final List<TimeBlock> blocks;
  final Map<String, Category> catMap;
  final ColorScheme scheme;
  final ValueChanged<DateTime> onDayTapped;
  final ValueChanged<TimeBlock> onBlockTapped;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group blocks by day index (0=Mon … 6=Sun)
    final blocksByDay = List.generate(7, (_) => <TimeBlock>[]);
    for (final b in blocks) {
      final dayStart = DateTime(
          b.startTime.year, b.startTime.month, b.startTime.day);
      final diff = dayStart.difference(weekStart).inDays;
      if (diff >= 0 && diff < 7) {
        blocksByDay[diff].add(b);
      }
    }

    return Column(
      children: [
        // ── Day header row (4.02) ──────────────────────────────────────
        _DayHeaderRow(
          weekStart: weekStart,
          today: today,
          scheme: scheme,
          onDayTapped: onDayTapped,
        ),
        const Divider(height: 1),
        // ── Scrollable grid body (4.03) ────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: _GridBody(
              weekStart: weekStart,
              blocksByDay: blocksByDay,
              catMap: catMap,
              scheme: scheme,
              today: today,
              onBlockTapped: onBlockTapped,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Day header row ─────────────────────────────────────────────────────────────

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({
    required this.weekStart,
    required this.today,
    required this.scheme,
    required this.onDayTapped,
  });

  final DateTime weekStart, today;
  final ColorScheme scheme;
  final ValueChanged<DateTime> onDayTapped;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: _timeColW), // gutter
        ...List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isToday = day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTapped(day),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: isToday
                            ? scheme.primary
                            : scheme.onSurface.withOpacity(0.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isToday
                            ? scheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 12,
                            color: isToday
                                ? Colors.white
                                : scheme.onSurface,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Grid body ──────────────────────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.weekStart,
    required this.blocksByDay,
    required this.catMap,
    required this.scheme,
    required this.today,
    required this.onBlockTapped,
  });

  final DateTime weekStart;
  final List<List<TimeBlock>> blocksByDay;
  final Map<String, Category> catMap;
  final ColorScheme scheme;
  final DateTime today;
  final ValueChanged<TimeBlock> onBlockTapped;

  @override
  Widget build(BuildContext context) {
    final totalHeight = _displayHours * _hourHeight;
    final now = DateTime.now();
    final isCurrentWeek = _mondayOf(now).isAtSameMomentAs(weekStart);

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels column
          SizedBox(
            width: _timeColW,
            child: Column(
              children: List.generate(_displayHours, (i) {
                final h = _startHour + i;
                return SizedBox(
                  height: _hourHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, left: 4),
                    child: Text(
                      '${h.toString().padLeft(2, '0')}',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        color: scheme.onSurface.withOpacity(0.25),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // 7 day columns
          ...List.generate(7, (dayIdx) {
            final day = weekStart.add(Duration(days: dayIdx));
            return Expanded(
              child: Stack(
                children: [
                  // Grid lines
                  Column(
                    children: List.generate(_displayHours, (i) {
                      return Container(
                        height: _hourHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: scheme.onSurface.withOpacity(0.05),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Current time line
                  if (isCurrentWeek &&
                      day.year == now.year &&
                      day.month == now.month &&
                      day.day == now.day)
                    _CurrentTimeLine(now: now, scheme: scheme),
                  // Time blocks for this day
                  ...blocksByDay[dayIdx].map((block) => _MiniBlock(
                    block: block,
                    catMap: catMap,
                    scheme: scheme,
                    onTap: () => onBlockTapped(block),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Current time line ──────────────────────────────────────────────────────────

class _CurrentTimeLine extends StatelessWidget {
  const _CurrentTimeLine({required this.now, required this.scheme});
  final DateTime now;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (now.hour - _startHour) * 60 + now.minute;
    if (totalMinutes < 0) return const SizedBox.shrink();
    final top = totalMinutes / 60 * _hourHeight;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Container(
        height: 1.5,
        color: AppColors.priorityHigh,
      ),
    );
  }
}

// ── Mini block chip ────────────────────────────────────────────────────────────

class _MiniBlock extends StatelessWidget {
  const _MiniBlock({
    required this.block,
    required this.catMap,
    required this.scheme,
    required this.onTap,
  });

  final TimeBlock block;
  final Map<String, Category> catMap;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final startMins = (block.startTime.hour - _startHour) * 60 +
        block.startTime.minute;
    final durationMins =
    block.endTime.difference(block.startTime).inMinutes.clamp(15, 24 * 60);

    if (startMins < 0) return const SizedBox.shrink();

    final top = startMins / 60 * _hourHeight;
    final height = (durationMins / 60 * _hourHeight).clamp(8.0, double.infinity);

    final cat = catMap[block.categoryId];
    final color = block.colorOverride != null
        ? AppColors.accentFromHex(block.colorOverride!)
        : cat != null
        ? AppColors.accentFromHex(cat.colorHex)
        : scheme.primary;

    return Positioned(
      top: top,
      left: 1,
      right: 1,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border(
              left: BorderSide(color: color, width: 2.5),
            ),
          ),
          padding: const EdgeInsets.only(left: 3, top: 1),
          child: height > 16
              ? Text(
            block.title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.clip,
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

DateTime _mondayOf(DateTime date) {
  final weekday = date.weekday; // 1=Mon … 7=Sun
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}