import 'package:isar/isar.dart';

part 'time_block.g.dart';

@Collection()
class TimeBlock {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String title;

  @Index()
  late DateTime startTime;

  late DateTime endTime;

  @Index()
  late String categoryId;

  /// 'high' | 'medium' | 'low'
  late String priority;

  @Index()
  String? taskId;

  @Index()
  late bool isRecurring;

  String? recurrenceRule;

  @Index()
  String? recurrenceParentId;

  /// Override hex color for this block (null = use category color)
  String? colorOverride;

  String? notes;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @Index()
  late bool isDeleted;

  // ── Factory ───────────────────────────────────────────────────────────────

  static TimeBlock create({
    required String uuid,
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
  }) {
    final now = DateTime.now();
    return TimeBlock()
      ..uuid = uuid
      ..title = title
      ..startTime = startTime
      ..endTime = endTime
      ..categoryId = categoryId
      ..priority = priority
      ..taskId = taskId
      ..isRecurring = isRecurring
      ..recurrenceRule = recurrenceRule
      ..colorOverride = colorOverride
      ..notes = notes
      ..isDeleted = false
      ..createdAt = now
      ..updatedAt = now;
  }

  @ignore
  Duration get duration => endTime.difference(startTime);
}