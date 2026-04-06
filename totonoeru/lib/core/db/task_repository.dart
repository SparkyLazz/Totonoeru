import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'collections.dart';
import 'isar_provider.dart';

const _uuid = Uuid();

class TaskRepository {
  TaskRepository(this._isar);
  final Isar _isar;

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<Task> createTask({
    required String title,
    String? notes,
    String? categoryId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? parentUuid,         // ← matches your field name
  }) async {
    final task = Task()
      ..uuid = _uuid.v4()
      ..title = title
      ..notes = notes
      ..categoryId = categoryId ?? ''
      ..priority = priority
      ..status = TaskStatus.pending
      ..dueDate = dueDate
      ..parentUuid = parentUuid  // ← fixed
      ..sortOrder = await _nextSortOrder()
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isDeleted = false;
    // ← removed isRecurring, doesn't exist in your schema

    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });

    return task;
  }

  // ── READ ──────────────────────────────────────────────────────────────────

  Future<List<Task>> getAllTasks() async {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentUuidIsNull()        // ← fixed
        .sortBySortOrder()
        .findAll();
  }

  Stream<List<Task>> watchAllTasks() {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentUuidIsNull()        // ← fixed
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Stream<List<Task>> watchTasksByCategory(String categoryId) {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentUuidIsNull()        // ← fixed
        .categoryIdEqualTo(categoryId)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Stream<Task?> watchTaskByUuid(String uuid) {
    return _isar.tasks
        .filter()
        .uuidEqualTo(uuid)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  Future<List<Task>> getSubtasks(String parentUuid) async {
    return _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .parentUuidEqualTo(parentUuid)  // ← fixed
        .sortBySortOrder()
        .findAll();
  }

  Future<Task?> getTaskByUuid(String uuid) async {
    return _isar.tasks.filter().uuidEqualTo(uuid).findFirst();
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  Future<void> setStatus(String uuid, TaskStatus status) async {
    final task = await getTaskByUuid(uuid);
    if (task == null) return;

    task.status = status;
    task.completedAt = status == TaskStatus.done ? DateTime.now() : null;
    task.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  Future<void> completeTask(String uuid) =>
      setStatus(uuid, TaskStatus.done);

  Future<void> uncompletedTask(String uuid) =>
      setStatus(uuid, TaskStatus.pending);

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> deleteTask(String uuid) async {
    final task = await getTaskByUuid(uuid);
    if (task == null) return;

    task.isDeleted = true;
    task.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  Future<void> restoreTask(String uuid) async {
    final task = await _isar.tasks
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
    if (task == null) return;

    task.isDeleted = false;
    task.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  Future<void> hardDeleteTask(String uuid) async {
    final task = await getTaskByUuid(uuid);
    if (task == null) return;

    await _isar.writeTxn(() async {
      await _isar.tasks.delete(task.id);
    });
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Future<int> _nextSortOrder() async {
    final last = await _isar.tasks
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrderDesc()
        .findFirst();
    return (last?.sortOrder ?? 0) + 1;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TaskRepository(isar);
});