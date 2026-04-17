import 'package:isar/isar.dart';
import '../models/focus_session.dart';
import '../models/productivity_stats.dart';
import '../services/database_service.dart';

class FocusRepository {
  FocusRepository._();
  static final instance = FocusRepository._();

  Isar get _isar => DatabaseService.instance.isar;

  // ── Helpers ───────────────────────────────────────────────────
  List<FocusSession> _sortDesc(List<FocusSession> list) {
    final sorted = [...list];
    sorted.sort((a, b) {
      final aTime = a.startedAt ?? DateTime(0);
      final bTime = b.startedAt ?? DateTime(0);
      return bTime.compareTo(aTime); // newest first
    });
    return sorted;
  }

  // ── Create ────────────────────────────────────────────────────
  Future<void> createSession(FocusSession session) async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
  }

  // ── Read ──────────────────────────────────────────────────────
  Future<FocusSession?> getSessionById(int id) async {
    return _isar.focusSessions.get(id);
  }

  Future<List<FocusSession>> getAllSessions() async {
    final all = await _isar.focusSessions.where().findAll();
    return _sortDesc(all);
  }

  /// Sessions started on [date] (midnight → midnight next day).
  Future<List<FocusSession>> getSessionsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final list = await _isar.focusSessions
        .filter()
        .startedAtBetween(start, end)
        .findAll();
    return _sortDesc(list);
  }

  /// Total focus minutes for the current week (Mon–Sun).
  Future<int> weeklyFocusMinutes() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final sessions = await _isar.focusSessions
        .filter()
        .completedEqualTo(true)
        .startedAtGreaterThan(weekStart)
        .findAll();
    final totalSeconds =
    sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return totalSeconds ~/ 60;
  }

  // ── Stream ────────────────────────────────────────────────────
  Stream<List<FocusSession>> watchTodaySessions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _isar.focusSessions
        .filter()
        .startedAtBetween(start, end)
        .watch(fireImmediately: true)
        .map(_sortDesc); // sort newest-first in stream transform
  }

  // ── Update ────────────────────────────────────────────────────
  Future<void> updateSession(FocusSession session) async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
  }

  // ── Delete ────────────────────────────────────────────────────
  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.delete(id);
    });
  }

  // ── Stats integration ─────────────────────────────────────────
  Future<void> recordCompletedSession(int durationSeconds) async {
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    await _isar.writeTxn(() async {
      var stats = await _isar.productivityStats
          .filter()
          .dateEqualTo(dateKey)
          .findFirst();

      if (stats == null) {
        stats = ProductivityStats()
          ..date = dateKey
          ..tasksCompleted = 0
          ..tasksCreated = 0
          ..focusMinutes = 0
          ..streakDay = 0;
      }

      stats.focusMinutes += durationSeconds ~/ 60;
      await _isar.productivityStats.put(stats);
    });
  }
}