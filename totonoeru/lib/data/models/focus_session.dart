import 'package:isar/isar.dart';

part 'focus_session.g.dart';

@Collection()
class FocusSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  String? taskId;

  late int durationSeconds;
  late int elapsedSeconds;

  late bool completed;

  @Index()
  late DateTime startedAt;

  DateTime? endedAt;

  // ── Factory ───────────────────────────────────────────────────────────────

  static FocusSession create({
    required String uuid,
    required int durationSeconds,
    String? taskId,
  }) {
    return FocusSession()
      ..uuid = uuid
      ..taskId = taskId
      ..durationSeconds = durationSeconds
      ..elapsedSeconds = 0
      ..completed = false
      ..startedAt = DateTime.now();
  }

  @ignore
  Duration get duration => Duration(seconds: durationSeconds);
  @ignore
  Duration get elapsed => Duration(seconds: elapsedSeconds);
  @ignore
  int get remainingSeconds => durationSeconds - elapsedSeconds;
}