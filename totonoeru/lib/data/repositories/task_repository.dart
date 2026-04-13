import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';

/// All task CRUD operations — tasks 2.01 + 2.03.
class TaskRepository {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  Isar get _isar => DatabaseService.instance.isar;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Task> createTask({
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
  }) async {
    // Compute next sortOrder for parent-level tasks
    int sortOrder = 0;
    if (parentTaskId == null) {
      final count = await _isar.tasks
          .filter()
          .isDeletedEqualTo(false)
          .parentTaskIdIsNull()
          .count();
      sortOrder = count;
    }

    final task = Task.create(
      uuid: _uuid.v4(),
      title: title,
      categoryId: categoryId,
      priority: priority,
      status: status,
      notes: notes,
      dueDate: dueDate,
      reminderTime: reminderTime,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      parentTaskId: parentTaskId,
      sortOrder: sortOrder,
    );

    await _isar.writeTxn(() => _isar.tasks.put(task));
    return task;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Task?> getTaskById(int id) => _isar.tasks.get(id);

  Future<Task?> getTaskByUuid(String uuid) =>
      _isar.tasks.getByUuid(uuid);

  /// All non-deleted root tasks (no parent), sorted by sortOrder.
  Future<List<Task>> getAllTasks({String? categoryId}) async {
    var query = _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentTaskIdIsNull();

    if (categoryId != null) {
      return query
          .and()
          .categoryIdEqualTo(categoryId)
          .sortBySortOrder()
          .findAll();
    }
    return query.sortBySortOrder().findAll();
  }

  /// Subtasks of a given parent uuid.
  Future<List<Task>> getSubtasks(String parentUuid) async {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentTaskIdEqualTo(parentUuid)
        .sortBySortOrder()
        .findAll();
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Task> updateTask(
      Task task, {
        String? title,
        String? categoryId,
        String? priority,
        String? status,
        String? notes,
        DateTime? dueDate,
        DateTime? reminderTime,
        bool? isRecurring,
        String? recurrenceRule,
      }) async {
    if (title != null) task.title = title;
    if (categoryId != null) task.categoryId = categoryId;
    if (priority != null) task.priority = priority;
    if (status != null) {
      task.status = status;
      if (status == 'done') task.completedAt = DateTime.now();
    }
    if (notes != null) task.notes = notes;
    if (dueDate != null) task.dueDate = dueDate;
    if (reminderTime != null) task.reminderTime = reminderTime;
    if (isRecurring != null) task.isRecurring = isRecurring;
    if (recurrenceRule != null) task.recurrenceRule = recurrenceRule;
    task.updatedAt = DateTime.now();

    await _isar.writeTxn(() => _isar.tasks.put(task));
    return task;
  }

  /// Toggle done ↔ pending.
  Future<Task> completeTask(Task task) async {
    final newStatus = task.status == 'done' ? 'pending' : 'done';
    return updateTask(task, status: newStatus);
  }

  // ── Soft delete / restore ─────────────────────────────────────────────────

  Future<void> softDeleteTask(Task task) async {
    task.isDeleted = true;
    task.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.tasks.put(task));
  }

  Future<void> restoreTask(Task task) async {
    task.isDeleted = false;
    task.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.tasks.put(task));
  }

  // ── Watch stream (for Riverpod) ───────────────────────────────────────────

  /// Stream that emits whenever the tasks collection changes.
  Stream<List<Task>> watchAllTasks({String? categoryId}) {
    if (categoryId != null) {
      return _isar.tasks
          .filter()
          .isDeletedEqualTo(false)
          .parentTaskIdIsNull()
          .and()
          .categoryIdEqualTo(categoryId)
          .sortBySortOrder()
          .watch(fireImmediately: true);
    }
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentTaskIdIsNull()
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Stream<List<Task>> watchSubtasks(String parentUuid) {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentTaskIdEqualTo(parentUuid)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }
}