import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/database_service.dart';
import '../../shared/widgets/app_fab.dart';
import '../../shared/widgets/app_toast.dart';
import 'add_task_sheet.dart';
import 'task_card.dart';
import '../../core/providers/tasks_provider.dart';

// ── Category cache provider ───────────────────────────────────────────────────

final _categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final cats = await DatabaseService.instance.isar.categorys.where().findAll();
  cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return cats;
});

// ── TasksScreen ───────────────────────────────────────────────────────────────

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  // Kanban toggle kept for Week 3 — list only for now
  bool _isKanban = false;

  void _openAddTask({Task? editTask}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(editTask: editTask),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);
    final sections = ref.watch(taskSectionsProvider);
    final filter = ref.watch(tasksFilterProvider);
    final cats = ref.watch(_categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tasks',
                            style: AppTypography.displayMedium.copyWith(
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'タスク一覧',
                            style: AppTypography.jpLight.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── View toggle (list/kanban) ──────────────────────
                    _ViewToggleButton(
                      isKanban: _isKanban,
                      onToggle: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isKanban = !_isKanban);
                      },
                    ),
                    const SizedBox(width: 8),
                    // ── Sort menu ──────────────────────────────────────
                    _SortMenuButton(
                      currentMode: filter.sortMode,
                      onSelect: (mode) {
                        ref.read(tasksFilterProvider.notifier).update(
                              (f) => f.copyWith(sortMode: mode),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Filter chips ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: cats.when(
                data: (categories) => _FilterChipRow(
                  categories: categories,
                  selectedCategoryId: filter.categoryId,
                  onSelect: (id) {
                    HapticFeedback.lightImpact();
                    ref.read(tasksFilterProvider.notifier).update(
                          (f) => f.categoryId == id
                          ? f.copyWith(clearCategory: true)
                          : f.copyWith(categoryId: id),
                    );
                  },
                ),
                loading: () => const SizedBox(height: 48),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── List body ─────────────────────────────────────────────────
            sections.when(
              data: (s) {
                if (s.inProgress.isEmpty &&
                    s.pending.isEmpty &&
                    s.completed.isEmpty) {
                  return const SliverFillRemaining(
                    child: _TasksEmptyState(),
                  );
                }
                return _TaskListSliver(
                  sections: s,
                  categories: cats.valueOrNull ?? [],
                  onComplete: (task) => _handleComplete(task),
                  onDelete: (task) => _handleDelete(task),
                  onEdit: (task) => _openAddTask(editTask: task),
                  onDuplicate: (task) => _handleDuplicate(task),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: _openAddTask,
        onAddTimeBlock: () {},
      ),
    );
  }

  void _handleComplete(Task task) {
    HapticFeedback.mediumImpact();
    TaskRepository.instance.completeTask(task);
  }

  void _handleDelete(Task task) {
    HapticFeedback.heavyImpact();
    TaskRepository.instance.softDeleteTask(task);
    AppToast.show(
      context,
      'Task deleted',
      onUndo: () => TaskRepository.instance.restoreTask(task),
    );
  }

  void _handleDuplicate(Task task) {
    TaskRepository.instance.createTask(
      title: '${task.title} (copy)',
      categoryId: task.categoryId,
      priority: task.priority,
      notes: task.notes,
      dueDate: task.dueDate,
    );
  }
}

// ── List sliver ───────────────────────────────────────────────────────────────

class _TaskListSliver extends StatelessWidget {
  const _TaskListSliver({
    required this.sections,
    required this.categories,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    required this.onDuplicate,
  });

  final TaskSections sections;
  final List<Category> categories;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDuplicate;

  ({String name, String colorHex, String nameJp})? _cat(String categoryId) {
    final c = categories.where((c) => c.uuid == categoryId).firstOrNull;
    if (c == null) return null;
    return (name: c.name, colorHex: c.colorHex, nameJp: c.nameJp);
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    void addSection(String label, int count, List<Task> tasks) {
      if (tasks.isEmpty) return;
      items.add(_SectionHeader(label: label, count: count));
      for (final task in tasks) {
        items.add(
          _SwipeableTaskCard(
            key: ValueKey(task.id),
            task: task,
            category: _cat(task.categoryId),
            onComplete: () => onComplete(task),
            onDelete: () => onDelete(task),
            onEdit: () => onEdit(task),
            onDuplicate: () => onDuplicate(task),
          ),
        );
      }
    }

    addSection('In Progress', sections.inProgress.length, sections.inProgress);
    addSection('Pending', sections.pending.length, sections.pending);
    addSection('Completed', sections.completed.length, sections.completed);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(items),
      ),
    );
  }
}

// ── Swipeable wrapper ─────────────────────────────────────────────────────────

class _SwipeableTaskCard extends ConsumerWidget {
  const _SwipeableTaskCard({
    super.key,
    required this.task,
    required this.category,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    required this.onDuplicate,
  });

  final Task task;
  final ({String name, String colorHex, String nameJp})? category;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      // ── Swipe right → complete (2.09) ──────────────────────────────
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: AppColors.statusDone.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check_circle_rounded,
            color: AppColors.statusDone, size: 24),
      ),
      // ── Swipe left → delete (2.10) ─────────────────────────────────
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded,
            color: AppColors.priorityHigh, size: 24),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
          return false; // don't remove from list, just toggle
        } else {
          onDelete();
          return false; // toast + undo handles removal
        }
      },
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.heavyImpact(); // 2.11
          _showContextMenu(context);
        },
        child: TaskCard(
          task: task,
          category: category,
          onTap: () => context.push('/tasks/${task.id}'),
          onComplete: onComplete,
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit', style: TextStyle(fontFamily: 'DMSans')),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Duplicate',
                  style: TextStyle(fontFamily: 'DMSans')),
              onTap: () {
                Navigator.pop(context);
                onDuplicate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded,
                  color: AppColors.priorityHigh),
              title: const Text('Delete',
                  style: TextStyle(
                      fontFamily: 'DMSans', color: AppColors.priorityHigh)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
    Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: textSecondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip row ───────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _Chip(
            label: 'All',
            isSelected: selectedCategoryId == null,
            color: accent,
            onTap: () => onSelect(null),
          ),
          ...categories.map((cat) {
            final color = AppColors.accentFromHex(cat.colorHex);
            return _Chip(
              label: cat.name,
              isSelected: selectedCategoryId == cat.uuid,
              color: color,
              onTap: () => onSelect(cat.uuid),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

// ── View toggle button ────────────────────────────────────────────────────────

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({required this.isKanban, required this.onToggle});
  final bool isKanban;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Icon(
          isKanban
              ? Icons.view_list_rounded
              : Icons.view_kanban_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

// ── Sort menu ─────────────────────────────────────────────────────────────────

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({
    required this.currentMode,
    required this.onSelect,
  });
  final TaskSortMode currentMode;
  final ValueChanged<TaskSortMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskSortMode>(
      icon: Icon(
        Icons.sort_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        _item(TaskSortMode.createdAt, 'Date created', Icons.add_circle_outline),
        _item(TaskSortMode.dueDate, 'Due date', Icons.schedule_rounded),
        _item(TaskSortMode.priority, 'Priority', Icons.flag_outlined),
        _item(TaskSortMode.manual, 'Manual', Icons.drag_handle_rounded),
      ],
      onSelected: onSelect,
    );
  }

  PopupMenuItem<TaskSortMode> _item(
      TaskSortMode mode, String label, IconData icon) =>
      PopupMenuItem(
        value: mode,
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontFamily: 'DMSans')),
            if (currentMode == mode) ...[
              const Spacer(),
              const Icon(Icons.check, size: 16),
            ],
          ],
        ),
      );
}

// ── Empty state (2.21) ────────────────────────────────────────────────────────

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textSecondary =
    Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple SVG-style illustration using widgets
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: accent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No tasks yet',
              style: AppTypography.headingMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first task',
              style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'タスクを追加してください',
              style: AppTypography.jpLight.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}