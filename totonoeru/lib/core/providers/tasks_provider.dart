import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task.dart';
import '';

// ── Task filter + sort state ──────────────────────────────────────────────────

enum TaskSortMode { dueDate, priority, createdAt, manual }

class TasksFilter {
  const TasksFilter({
    this.categoryId,
    this.sortMode = TaskSortMode.createdAt,
    this.showCompleted = true,
  });

  final String? categoryId;
  final TaskSortMode sortMode;
  final bool showCompleted;

  TasksFilter copyWith({
    String? categoryId,
    bool clearCategory = false,
    TaskSortMode? sortMode,
    bool? showCompleted,
  }) {
    return TasksFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      sortMode: sortMode ?? this.sortMode,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }
}

// ── Filter provider ───────────────────────────────────────────────────────────

final tasksFilterProvider = StateProvider<TasksFilter>(
      (ref) => const TasksFilter(),
);

// ── Main tasks stream provider (task 2.02) ────────────────────────────────────

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final filter = ref.watch(tasksFilterProvider);
  return TaskRepository.instance.watchAllTasks(categoryId: filter.categoryId);
});

// ── Derived: sorted + filtered tasks ─────────────────────────────────────────

final sortedTasksProvider = Provider.autoDispose<AsyncValue<List<Task>>>((ref) {
  final raw = ref.watch(tasksProvider);
  final filter = ref.watch(tasksFilterProvider);

  return raw.whenData((tasks) {
    var filtered = tasks.where((t) {
      if (!filter.showCompleted && t.status == 'done') return false;
      return true;
    }).toList();

    switch (filter.sortMode) {
      case TaskSortMode.dueDate:
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TaskSortMode.priority:
        const order = {'high': 0, 'medium': 1, 'low': 2};
        filtered.sort((a, b) =>
            (order[a.priority] ?? 1).compareTo(order[b.priority] ?? 1));
      case TaskSortMode.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSortMode.manual:
        filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return filtered;
  });
});

// ── Section grouping ──────────────────────────────────────────────────────────

class TaskSections {
  const TaskSections({
    required this.inProgress,
    required this.pending,
    required this.completed,
  });

  final List<Task> inProgress;
  final List<Task> pending;
  final List<Task> completed;

  int get totalActive => inProgress.length + pending.length;
}

final taskSectionsProvider = Provider.autoDispose<AsyncValue<TaskSections>>((ref) {
  final sorted = ref.watch(sortedTasksProvider);
  return sorted.whenData((tasks) => TaskSections(
    inProgress: tasks.where((t) => t.status == 'inProgress').toList(),
    pending: tasks.where((t) => t.status == 'pending').toList(),
    completed: tasks.where((t) => t.status == 'done').toList(),
  ));
});

// ── Subtasks provider ─────────────────────────────────────────────────────────

final subtasksProvider = StreamProvider.autoDispose
    .family<List<Task>, String>((ref, parentUuid) {
  return TaskRepository.instance.watchSubtasks(parentUuid);
});

// ── Single task provider ──────────────────────────────────────────────────────

final singleTaskProvider =
FutureProvider.autoDispose.family<Task?, int>((ref, id) {
  return TaskRepository.instance.getTaskById(id);
});