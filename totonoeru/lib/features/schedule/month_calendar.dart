// lib/features/schedule/month_calendar.dart
//
// Tasks 4.06–4.10 — Month Calendar
// 4.06  MonthCalendar widget scaffold + prev/next month nav
// 4.07  6-week grid (42 cells), correct start day (Monday-first)
// 4.08  Dot density per day (1–3 dots based on block count)
// 4.09  Selected day highlight ring
// 4.10  Tap day → writes selectedDateProvider + callback to switch to day view

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/time_block.dart';

// ── MonthCalendar ──────────────────────────────────────────────────────────────

class MonthCalendar extends ConsumerStatefulWidget {
  const MonthCalendar({
    super.key,
    required this.onDayTapped,
  });

  final ValueChanged<DateTime> onDayTapped;

  @override
  ConsumerState<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends ConsumerState<MonthCalendar> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedDateProvider);
    _year = selected.year;
    _month = selected.month;
  }

  void _prevMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  void _goToToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    setState(() {
      _year = now.year;
      _month = now.month;
    });
  }

  void _tapDay(DateTime day) {
    HapticFeedback.lightImpact();
    ref.read(selectedDateProvider.notifier).state =
        DateTime(day.year, day.month, day.day);
    widget.onDayTapped(day);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.4);

    // Fetch blocks for the entire month + overflow week
    final firstDay = DateTime(_year, _month, 1);
    final lastDay = DateTime(_year, _month + 1, 0); // last day of month
    final rangeStart = _mondayOfWeek(firstDay);
    final rangeEnd = rangeStart.add(const Duration(days: 41));

    final rangeAsync = ref.watch(rangeBlocksProvider(
      (from: rangeStart, to: rangeEnd),
    ));

    final blockCountByDay = <String, int>{};
    for (final b in rangeAsync.valueOrNull ?? <TimeBlock>[]) {
      final key = _dayKey(b.startTime);
      blockCountByDay[key] = (blockCountByDay[key] ?? 0) + 1;
    }

    final selected = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────────────────
        _CalendarHeader(
          year: _year,
          month: _month,
          onPrev: _prevMonth,
          onNext: _nextMonth,
          onToday: _goToToday,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          scheme: scheme,
        ),
        const SizedBox(height: 12),

        // ── Weekday labels (Mon–Sun) ────────────────────────────────────
        _WeekdayLabels(textSecondary: textSecondary),
        const SizedBox(height: 4),

        // ── Calendar grid (4.07) ───────────────────────────────────────
        _CalendarGrid(
          year: _year,
          month: _month,
          today: today,
          selected: selected,
          blockCountByDay: blockCountByDay,
          scheme: scheme,
          onDayTapped: _tapDay,
        ),

        const SizedBox(height: 12),

        // ── Mini legend ────────────────────────────────────────────────
        _DotLegend(scheme: scheme),
      ],
    );
  }
}

// ── Calendar header ────────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.year,
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.textPrimary,
    required this.textSecondary,
    required this.scheme,
  });

  final int year, month;
  final VoidCallback onPrev, onNext, onToday;
  final Color textPrimary, textSecondary;
  final ColorScheme scheme;

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _monthNames[month],
                  style: AppTypography.headingSmall.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$year',
                  style: AppTypography.labelSmall.copyWith(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _ArrowBtn(icon: Icons.chevron_left_rounded, onTap: onPrev, scheme: scheme),
          const SizedBox(width: 4),
          _ArrowBtn(icon: Icons.chevron_right_rounded, onTap: onNext, scheme: scheme),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onTap, required this.scheme});
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
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

// ── Weekday labels ─────────────────────────────────────────────────────────────

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.textSecondary});
  final Color textSecondary;

  static const _labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _labels.map((l) => Expanded(
          child: Center(
            child: Text(
              l,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ── Calendar grid (4.07 + 4.08 + 4.09) ────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.today,
    required this.selected,
    required this.blockCountByDay,
    required this.scheme,
    required this.onDayTapped,
  });

  final int year, month;
  final DateTime today, selected;
  final Map<String, int> blockCountByDay;
  final ColorScheme scheme;
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final gridStart = _mondayOfWeek(firstDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.85,
        ),
        itemCount: 42,
        itemBuilder: (context, i) {
          final day = gridStart.add(Duration(days: i));
          final isCurrentMonth = day.month == month && day.year == year;
          final isToday = day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final blockCount = blockCountByDay[_dayKey(day)] ?? 0;

          return _DayCell(
            day: day,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelected: isSelected,
            blockCount: blockCount,
            scheme: scheme,
            onTap: () => onDayTapped(day),
          );
        },
      ),
    );
  }
}

// ── Day cell (4.08 + 4.09) ─────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.blockCount,
    required this.scheme,
    required this.onTap,
  });

  final DateTime day;
  final bool isCurrentMonth, isToday, isSelected;
  final int blockCount;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = scheme.primary;

    Color numColor;
    if (!isCurrentMonth) {
      numColor = scheme.onSurface.withOpacity(0.2);
    } else if (isSelected || isToday) {
      numColor = Colors.white;
    } else {
      numColor = scheme.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? accent
                  : isToday
                  ? accent.withOpacity(0.7)
                  : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: accent, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 13,
                  color: numColor,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
          // Dot density (4.08)
          const SizedBox(height: 3),
          _DotRow(
            count: blockCount,
            isCurrentMonth: isCurrentMonth,
            accent: accent,
          ),
        ],
      ),
    );
  }
}

// ── Dot row (4.08) ─────────────────────────────────────────────────────────────

class _DotRow extends StatelessWidget {
  const _DotRow({
    required this.count,
    required this.isCurrentMonth,
    required this.accent,
  });

  final int count;
  final bool isCurrentMonth;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (count == 0 || !isCurrentMonth) {
      return const SizedBox(height: 5);
    }
    // 1 dot = 1, 2 dots = 2, 3 dots = 3+ blocks
    final dots = count.clamp(1, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dots, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: accent.withOpacity(
            dots == 3 ? 0.9 : dots == 2 ? 0.7 : 0.5,
          ),
          shape: BoxShape.circle,
        ),
      )),
    );
  }
}

// ── Dot legend ─────────────────────────────────────────────────────────────────

class _DotLegend extends StatelessWidget {
  const _DotLegend({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final accent = scheme.primary;
    final textSecondary = scheme.onSurface.withOpacity(0.4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _LegendDot(color: accent.withOpacity(0.5), label: '1', textSecondary: textSecondary),
          const SizedBox(width: 10),
          _LegendDot(color: accent.withOpacity(0.7), label: '2', textSecondary: textSecondary),
          const SizedBox(width: 10),
          _LegendDot(color: accent.withOpacity(0.9), label: '3+', textSecondary: textSecondary),
          const SizedBox(width: 4),
          Text(
            ' blocks',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.textSecondary,
  });
  final Color color;
  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

DateTime _mondayOfWeek(DateTime date) {
  return DateTime(
      date.year, date.month, date.day - (date.weekday - 1));
}

String _dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';