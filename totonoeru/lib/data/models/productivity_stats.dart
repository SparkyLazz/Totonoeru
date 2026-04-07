import 'package:isar/isar.dart';

part 'productivity_stats.g.dart';

@Collection()
class ProductivityStats {
  Id id = Isar.autoIncrement;

  /// One record per calendar day — indexed for fast lookup.
  @Index(unique: true)
  late DateTime date;

  late int tasksCompleted;
  late int tasksCreated;
  late int focusMinutes;

  /// Streak day count as of this date.
  late int streakDay;

  // ── Factory ───────────────────────────────────────────────────────────────

  static ProductivityStats forDate(DateTime date) {
    // Normalize to midnight
    final normalized = DateTime(date.year, date.month, date.day);
    return ProductivityStats()
      ..date = normalized
      ..tasksCompleted = 0
      ..tasksCreated = 0
      ..focusMinutes = 0
      ..streakDay = 0;
  }

  /// True if this record represents today.
  @ignore
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}