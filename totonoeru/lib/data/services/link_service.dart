// lib/data/services/link_service.dart
//
// Tasks 4.20–4.22 — Task ↔ Time Block linking
// 4.20  linkTaskToBlock(task, block) — writes both sides of the relationship
// 4.21  unlinkTaskFromBlock(task, block) — clears both sides
// 4.22  getBlockForTask(task) — returns the linked TimeBlock if any

import '../models/task.dart';
import '../models/time_block.dart';
import '../repositories/task_repository.dart';
import '../repositories/time_block_repository.dart';

/// Manages the bidirectional Task ↔ TimeBlock link.
///
/// Invariant:
///   task.scheduleBlockId == block.uuid  AND
///   block.taskId == task.uuid
///
/// Both sides are always updated atomically (two Isar writes in sequence).
/// Isar 3 does not support cross-collection transactions, so we write
/// task first, block second — consistent with the rest of the codebase.
abstract final class LinkService {
  // ── Link ────────────────────────────────────────────────────────────────

  /// Link [task] to [block]. Unlinks any previous associations first.
  static Future<void> linkTaskToBlock(Task task, TimeBlock block) async {
    // 1. Clear previous block's taskId if task was already linked
    if (task.scheduleBlockId != null &&
        task.scheduleBlockId != block.uuid) {
      final oldBlock = await TimeBlockRepository.instance
          .getByUuid(task.scheduleBlockId!);
      if (oldBlock != null) {
        oldBlock.taskId = null;
        oldBlock.updatedAt = DateTime.now();
        await TimeBlockRepository.instance.updateTimeBlock(oldBlock);
      }
    }

    // 2. Clear previous task's scheduleBlockId if block was already linked
    if (block.taskId != null && block.taskId != task.uuid) {
      final oldTask =
      await TaskRepository.instance.getTaskByUuid(block.taskId!);
      if (oldTask != null) {
        oldTask.scheduleBlockId = null;
        oldTask.updatedAt = DateTime.now();
        await TaskRepository.instance.updateTask(oldTask);
      }
    }

    // 3. Write task side
    task.scheduleBlockId = block.uuid;
    task.updatedAt = DateTime.now();
    await TaskRepository.instance.updateTask(task);

    // 4. Write block side
    block.taskId = task.uuid;
    block.updatedAt = DateTime.now();
    await TimeBlockRepository.instance.updateTimeBlock(block);
  }

  // ── Unlink ───────────────────────────────────────────────────────────────

  /// Remove the link between [task] and [block].
  static Future<void> unlinkTaskFromBlock(Task task, TimeBlock block) async {
    task.scheduleBlockId = null;
    task.updatedAt = DateTime.now();
    await TaskRepository.instance.updateTask(task);

    block.taskId = null;
    block.updatedAt = DateTime.now();
    await TimeBlockRepository.instance.updateTimeBlock(block);
  }

  // ── Query ────────────────────────────────────────────────────────────────

  /// Returns the linked TimeBlock for [task], or null if not linked.
  static Future<TimeBlock?> getBlockForTask(Task task) async {
    if (task.scheduleBlockId == null) return null;
    return TimeBlockRepository.instance.getByUuid(task.scheduleBlockId!);
  }

  /// Returns the linked Task for [block], or null if not linked.
  static Future<Task?> getTaskForBlock(TimeBlock block) async {
    if (block.taskId == null) return null;
    return TaskRepository.instance.getTaskByUuid(block.taskId!);
  }
}