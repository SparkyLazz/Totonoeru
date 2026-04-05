import 'package:isar/isar.dart';

// Run: dart run build_runner build --delete-conflicting-outputs
part 'collections.g.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, done, archived }

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  String? notes;
  late String categoryId;

  @enumerated
  late TaskPriority priority;

  @enumerated
  late TaskStatus status;

  DateTime? dueDate;
  DateTime? reminder;
  String? rrule;
  String? parentUuid;
  DateTime? completedAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
  int sortOrder = 0;
}

@Collection()
class TimeBlock {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  late String categoryId;
  late DateTime startTime;
  late DateTime endTime;
  String? rrule;
  String? linkedTaskUuid;
  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

@Collection()
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  String? nameJP;
  late int colorValue;
  late int sortOrder;
  bool isBuiltIn = false;
  late DateTime createdAt;
}

@Collection()
class FocusSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  String? linkedTaskUuid;
  late int durationSeconds;
  late DateTime startedAt;
  late DateTime endedAt;
  bool completed = false;
}

@Collection()
class DailyStat {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String dateKey;

  late int tasksCompleted;
  late int tasksCreated;
  late int focusMinutes;
  late int timeBlocksCompleted;
}
