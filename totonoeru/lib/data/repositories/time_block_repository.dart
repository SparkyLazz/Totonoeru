// lib/data/repositories/time_block_repository.dart
//
// Task 3.10 — TimeBlockRepository: CRUD + overlap detection

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/time_block.dart';
import '../services/database_service.dart';

class TimeBlockRepository {
  TimeBlockRepository._();
  static final TimeBlockRepository instance = TimeBlockRepository._();

  Isar get _isar => DatabaseService.instance.isar;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────────────

  Future<TimeBlock> createTimeBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String categoryId,
    String priority = 'medium',
    String? taskId,
    bool isRecurring = false,
    String? recurrenceRule,
    String? colorOverride,
    String? notes,
  }) async {
    final block = TimeBlock.create(
      uuid: _uuid.v4(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      categoryId: categoryId,
      priority: priority,
      taskId: taskId,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      colorOverride: colorOverride,
      notes: notes,
    );
    await _isar.writeTxn(() => _isar.timeBlocks.put(block));
    return block;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<TimeBlock?> getByUuid(String uuid) =>
      _isar.timeBlocks.getByUuid(uuid);

  /// All non-deleted blocks for a given calendar day, sorted by startTime.
  Future<List<TimeBlock>> getBlocksForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _isar.timeBlocks
        .where()
        .startTimeBetween(start, end, includeUpper: false)
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  /// All non-deleted blocks within a date range (inclusive), for week view.
  Future<List<TimeBlock>> getBlocksForRange(
      DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day)
        .add(const Duration(days: 1));
    return _isar.timeBlocks
        .where()
        .startTimeBetween(start, end, includeUpper: false)
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  // ── Overlap detection ─────────────────────────────────────────────────────
  //
  // Two blocks overlap when: blockStart < newEnd && blockEnd > newStart.
  // We use this in the UI to warn (not block) the user.

  Future<List<TimeBlock>> getOverlapping({
    required DateTime start,
    required DateTime end,
    String? excludeUuid, // pass when editing — don't flag self
  }) async {
    // Fetch all blocks on the same day first (cheap), then filter in Dart.
    final dayBlocks = await getBlocksForDay(start);
    return dayBlocks.where((b) {
      if (excludeUuid != null && b.uuid == excludeUuid) return false;
      return b.startTime.isBefore(end) && b.endTime.isAfter(start);
    }).toList();
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<TimeBlock> updateTimeBlock(
      TimeBlock block, {
        String? title,
        DateTime? startTime,
        DateTime? endTime,
        String? categoryId,
        String? priority,
        String? taskId,
        bool? isRecurring,
        String? recurrenceRule,
        String? colorOverride,
        String? notes,
      }) async {
    if (title != null) block.title = title;
    if (startTime != null) block.startTime = startTime;
    if (endTime != null) block.endTime = endTime;
    if (categoryId != null) block.categoryId = categoryId;
    if (priority != null) block.priority = priority;
    if (taskId != null) block.taskId = taskId;
    if (isRecurring != null) block.isRecurring = isRecurring;
    if (recurrenceRule != null) block.recurrenceRule = recurrenceRule;
    if (colorOverride != null) block.colorOverride = colorOverride;
    if (notes != null) block.notes = notes;
    block.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.timeBlocks.put(block));
    return block;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> softDelete(TimeBlock block) async {
    block.isDeleted = true;
    block.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.timeBlocks.put(block));
  }

  Future<void> restore(TimeBlock block) async {
    block.isDeleted = false;
    block.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.timeBlocks.put(block));
  }

  // ── Watch streams (for Riverpod) ──────────────────────────────────────────

  /// Emits fresh list whenever anything in the collection changes.
  /// Filtered to the given day in Dart (Isar 3 stream + filter).
  Stream<List<TimeBlock>> watchBlocksForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _isar.timeBlocks
        .where()
        .startTimeBetween(start, end, includeUpper: false)
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }

  Stream<List<TimeBlock>> watchBlocksForRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day)
        .add(const Duration(days: 1));
    return _isar.timeBlocks
        .where()
        .startTimeBetween(start, end, includeUpper: false)
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }
}