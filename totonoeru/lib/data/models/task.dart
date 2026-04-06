import 'package:isar/isar.dart';

part 'task.g.dart';

// ── Enums stored as strings ────────────────────────────────────────────────────

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, done, archived }

// ── Isar Collection ───────────────────────────────────────────────────────────

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String title;

  String? notes;

  @Index()
  late String categoryId;

  /// Stored as enum name string: 'high' | 'medium' | 'low'
  @Index()
  late String priority;

  /// Stored as enum name string: 'pending' | 'inProgress' | 'done' | 'archived'
  @Index()
  late String status;

  @Index()
  DateTime? dueDate;

  DateTime? reminderTime;

  @Index()
  late bool isRecurring;

  String? recurrenceRule;

  @Index()
  String? parentTaskId;

  String? scheduleBlockId;

  late int sortOrder;

  DateTime? completedAt;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @Index()
  late bool isDeleted;

  // ── Computed helpers (not stored) ────────────────────────────────────────

  @ignore
  TaskPriority get priorityEnum => TaskPriority.values.byName(priority);
  @ignore
  TaskStatus get statusEnum => TaskStatus.values.byName(status);

  @ignore
  bool get isCompleted => status == 'done';
  @ignore
  bool get isPending => status == 'pending';
  @ignore
  bool get isSubtask => parentTaskId != null;

  // ── Factory ───────────────────────────────────────────────────────────────

  static Task create({
    required String uuid,
    required String title,
    required String categoryId,
    String priority = 'medium',
    String status = 'pending',
    String? notes,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool isRecurring = false,
    String? recurrenceRule,
    String? parentTaskId,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return Task()
      ..uuid = uuid
      ..title = title
      ..categoryId = categoryId
      ..priority = priority
      ..status = status
      ..notes = notes
      ..dueDate = dueDate
      ..reminderTime = reminderTime
      ..isRecurring = isRecurring
      ..recurrenceRule = recurrenceRule
      ..parentTaskId = parentTaskId
      ..sortOrder = sortOrder
      ..isDeleted = false
      ..createdAt = now
      ..updatedAt = now;
  }
}