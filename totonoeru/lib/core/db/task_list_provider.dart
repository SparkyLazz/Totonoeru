import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'collections.dart';
import 'task_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TASK LIST PROVIDER
// Watches all tasks and exposes filtered + grouped views.
// The UI reads from these — never from the repository directly.
// ─────────────────────────────────────────────────────────────────────────────

// ── Active filter (category uuid, or null = All) ──────────────────────────────
final activeCategoryFilterProvider = StateProvider<String?>((ref) => null);

// ── Raw stream of all tasks from Isar ────────────────────────────────────────
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final categoryId = ref.watch(activeCategoryFilterProvider);

  if (categoryId == null) {
    return repo.watchAllTasks();
  } else {
    return repo.watchTasksByCategory(categoryId);
  }
});

// ── Grouped tasks: In Progress / Pending / Done ───────────────────────────────
final groupedTasksProvider = Provider<Map<TaskStatus, List<Task>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);

  return tasksAsync.when(
    data: (tasks) {
      final inProgress = tasks
          .where((t) => t.status == TaskStatus.inProgress)
          .toList();
      final pending = tasks
          .where((t) => t.status == TaskStatus.pending)
          .toList();
      final done = tasks
          .where((t) => t.status == TaskStatus.done)
          .toList();

      return {
        TaskStatus.inProgress: inProgress,
        TaskStatus.pending: pending,
        TaskStatus.done: done,
      };
    },
    loading: () => {
      TaskStatus.inProgress: [],
      TaskStatus.pending: [],
      TaskStatus.done: [],
    },
    error: (_, __) => {
      TaskStatus.inProgress: [],
      TaskStatus.pending: [],
      TaskStatus.done: [],
    },
  );
});

// ── Task counts for the summary line ─────────────────────────────────────────
final taskCountsProvider = Provider<({int done, int inProgress, int pending})>((ref) {
  final grouped = ref.watch(groupedTasksProvider);
  return (
  done: grouped[TaskStatus.done]?.length ?? 0,
  inProgress: grouped[TaskStatus.inProgress]?.length ?? 0,
  pending: grouped[TaskStatus.pending]?.length ?? 0,
  );
});