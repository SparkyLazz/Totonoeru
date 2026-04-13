// lib/features/schedule/week_strip.dart
//
// Task 3.13 — WeekStrip: 7-day row, active day highlighted, writes selectedDateProvider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_typography.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _daysJp = ['月', '火', '水', '木', '金', '土', '日'];

class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  /// Returns the Monday of the week containing [date].
  static DateTime _weekStart(DateTime date) {
    final weekday = date.weekday; // 1=Mon … 7=Sun
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final weekStart = _weekStart(selected);

    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, i) {
          final day = weekStart.add(Duration(days: i));
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final isToday = day.isAtSameMomentAs(todayDate);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(selectedDateProvider.notifier).state = day;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent
                    : isToday
                    ? accent.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: accent.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day name
                  Text(
                    _days[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : scheme.onSurface.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Day number
                  Text(
                    '${day.day}',
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? accent
                          : scheme.onSurface,
                      fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Today dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? (isSelected ? Colors.white : accent)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}