// lib/core/providers/home_providers.dart
//
// Tasks 4.11–4.14 — Home dashboard providers
// 4.11  todayBlocksProvider — upcoming blocks for today (sorted, non-deleted)
// 4.12  todayTaskSummaryProvider — done/inProgress/pending counts
// 4.13  streakProvider — reads ProductivityStats to compute current streak
// 4.14  statsForRangeProvider — weekly stats for stat chips

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/productivity_stats.dart';
import '../../data/models/time_block.dart';
import '../../data/models/task.dart';
import '../../data/services/database_service.dart';
import '../../data/repositories/time_block_repository.dart';
import '../../data/repositories/task_repository.dart';

// ── Today's upcoming blocks ────────────────────────────────────────────────────

final upcomingBlocksProvider = FutureProvider.autoDispose<List<TimeBlock>>((ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final blocks = await TimeBlockRepository.instance.getBlocksForDay(today);

  // Sort by startTime, show next 3 that haven't ended yet
  final upcoming = blocks
      .where((b) => b.endTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  return upcoming.take(3).toList();
});

// ── Today's task summary ───────────────────────────────────────────────────────

class TodayTaskSummary {
  const TodayTaskSummary({
    required this.done,
    required this.inProgress,
    required this.pending,
  });
  final int done;
  final int inProgress;
  final int pending;
  int get total => done + inProgress + pending;
  double get completionRate => total == 0 ? 0 : done / total;
}

final todayTaskSummaryProvider =
FutureProvider.autoDispose<TodayTaskSummary>((ref) async {
  final tasks = await TaskRepository.instance.getAllTasks();

  // Only root tasks, not archived/deleted
  final active = tasks.where((t) =>
  t.status != 'archived' && !t.isDeleted && t.parentTaskId == null);

  return TodayTaskSummary(
    done: active.where((t) => t.status == 'done').length,
    inProgress: active.where((t) => t.status == 'inProgress').length,
    pending: active.where((t) => t.status == 'pending').length,
  );
});

// ── Streak provider ────────────────────────────────────────────────────────────

final streakProvider = FutureProvider.autoDispose<int>((ref) async {
  final isar = DatabaseService.instance.isar;
  final today = DateTime.now();
  final todayKey = DateTime(today.year, today.month, today.day);

  // Walk backwards from today counting consecutive days with completed tasks
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final day = todayKey.subtract(Duration(days: i));
    final stat = await isar.productivityStats.getByDate(day);
    if (stat != null && stat.tasksCompleted > 0) {
      streak++;
    } else if (i > 0) {
      // Gap — streak ends (don't penalize if today has no completed task yet)
      break;
    }
  }
  return streak;
});

// ── Weekly focus minutes ───────────────────────────────────────────────────────

final weeklyFocusProvider = FutureProvider.autoDispose<int>((ref) async {
  final isar = DatabaseService.instance.isar;
  final now = DateTime.now();
  final monday = DateTime(
      now.year, now.month, now.day - (now.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));

  int total = 0;
  for (int i = 0; i <= 6; i++) {
    final day = monday.add(Duration(days: i));
    final stat = await isar.productivityStats.getByDate(day);
    if (stat != null) total += stat.focusMinutes;
  }
  return total;
});