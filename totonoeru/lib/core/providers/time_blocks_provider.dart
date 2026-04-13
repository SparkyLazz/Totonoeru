// lib/core/providers/time_blocks_provider.dart
//
// Task 3.11 — TimeBlocksProvider: Riverpod, watches Isar, filters by date

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/time_block.dart';
import '../../data/repositories/time_block_repository.dart';

// ── Selected date provider ────────────────────────────────────────────────────
//
// The schedule screen drives everything via this single date.
// WeekStrip and the timeline both watch it.

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ── Day blocks provider ───────────────────────────────────────────────────────
//
// Watches blocks for the currently selected day.
// Re-subscribes automatically when selectedDate changes.

final dayBlocksProvider = StreamProvider<List<TimeBlock>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return TimeBlockRepository.instance.watchBlocksForDay(date);
});

// ── Range blocks provider ─────────────────────────────────────────────────────
//
// Used by the week view — pass a DateRange record.

final rangeBlocksProvider =
StreamProvider.family<List<TimeBlock>, ({DateTime from, DateTime to})>(
      (ref, range) {
    return TimeBlockRepository.instance
        .watchBlocksForRange(range.from, range.to);
  },
);

// ── Single block provider ─────────────────────────────────────────────────────
//
// For the detail sheet — look up by uuid.

final singleBlockProvider =
FutureProvider.family<TimeBlock?, String>((ref, uuid) {
  return TimeBlockRepository.instance.getByUuid(uuid);
});