import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

// ── Column config ─────────────────────────────────────────────────────────────

class _KanbanCol {
  const _KanbanCol({
    required this.status,
    required this.label,
    required this.jpLabel,
    required this.color,
    required this.icon,
  });
  final TaskStatus status;
  final String label;
  final String jpLabel;
  final Color color;
  final IconData icon;
}

const _cols = [
  _KanbanCol(
    status: TaskStatus.pending,
    label: 'Pending',
    jpLabel: '未着手',
    color: Color(0xFF8B9EC7),
    icon: Icons.radio_button_unchecked_rounded,
  ),
  _KanbanCol(
    status: TaskStatus.inProgress,
    label: 'In Progress',
    jpLabel: '進行中',
    color: Color(0xFFF59E0B),
    icon: Icons.timelapse_rounded,
  ),
  _KanbanCol(
    status: TaskStatus.done,
    label: 'Done',
    jpLabel: '完了',
    color: Color(0xFF3CBFAE),
    icon: Icons.check_circle_outline_rounded,
  ),
];

// ── KanbanBoard ───────────────────────────────────────────────────────────────

class KanbanBoard extends ConsumerStatefulWidget {
  const KanbanBoard({
    super.key,
    required this.tasks,
    required this.categories,
    required this.onTaskTap,
  });

  final List<Task> tasks;
  final List<Category> categories;
  final ValueChanged<Task> onTaskTap;

  @override
  ConsumerState<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends ConsumerState<KanbanBoard> {
  Task? _dragging;
  TaskStatus? _hoveredCol;

  Map<String, Category> get _catMap =>
      {for (final c in widget.categories) c.uuid: c};

  List<Task> _tasksForStatus(TaskStatus s) => widget.tasks
      .where((t) => t.statusEnum == s && t.parentTaskId == null)
      .toList();

  // FIX: use TaskRepository.instance (singleton), mutate fields directly
  Future<void> _moveTask(Task task, TaskStatus newStatus) async {
    if (task.statusEnum == newStatus) return;
    HapticFeedback.mediumImpact();
    await TaskRepository.instance.updateTask(
      task,
      status: newStatus.name,
    );
    ref.invalidate(taskSectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: _cols.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final col = _cols[i];
          final colTasks = _tasksForStatus(col.status);
          final isHovered = _hoveredCol == col.status;

          return DragTarget<Task>(
            onWillAcceptWithDetails: (details) {
              setState(() => _hoveredCol = col.status);
              return details.data.statusEnum != col.status;
            },
            onLeave: (_) => setState(() => _hoveredCol = null),
            onAcceptWithDetails: (details) {
              setState(() => _hoveredCol = null);
              _moveTask(details.data, col.status);
            },
            builder: (context, _, __) {
              return _KanbanColumn(
                col: col,
                tasks: colTasks,
                catMap: _catMap,
                isHovered: isHovered,
                dragging: _dragging,
                onDragStarted: (t) => setState(() => _dragging = t),
                onDragEnd: () => setState(() {
                  _dragging = null;
                  _hoveredCol = null;
                }),
                onTaskTap: widget.onTaskTap,
              );
            },
          );
        },
      ),
    );
  }
}

// ── KanbanColumn ──────────────────────────────────────────────────────────────

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.col,
    required this.tasks,
    required this.catMap,
    required this.isHovered,
    required this.dragging,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onTaskTap,
  });

  final _KanbanCol col;
  final List<Task> tasks;
  final Map<String, Category> catMap;
  final bool isHovered;
  final Task? dragging;
  final ValueChanged<Task> onDragStarted;
  final VoidCallback onDragEnd;
  final ValueChanged<Task> onTaskTap;

  static const double _colWidth = 260;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _colWidth,
      decoration: BoxDecoration(
        color: isHovered
            ? col.color.withOpacity(isDark ? 0.15 : 0.08)
            : scheme.surface.withOpacity(isDark ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovered
              ? col.color.withOpacity(0.5)
              : scheme.onSurface.withOpacity(0.07),
          width: isHovered ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ColHeader(col: col, count: tasks.length),
          Expanded(
            child: tasks.isEmpty
                ? _EmptyColState(col: col)
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final task = tasks[i];
                final isDraggingThis = dragging?.id == task.id;
                return Opacity(
                  opacity: isDraggingThis ? 0.35 : 1.0,
                  child: _DraggableCard(
                    task: task,
                    category: catMap[task.categoryId],
                    onDragStarted: () => onDragStarted(task),
                    onDragEnd: onDragEnd,
                    onTap: () => onTaskTap(task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Column header ─────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  const _ColHeader({required this.col, required this.count});
  final _KanbanCol col;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Icon(col.icon, size: 16, color: col.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  col.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: col.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  col.jpLabel,
                  style: AppTypography.jpLight.copyWith(
                    fontSize: 10,
                    color: scheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: col.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: col.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Draggable card ────────────────────────────────────────────────────────────

class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.task,
    required this.category,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onTap,
  });

  final Task task;
  final Category? category;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      onDragStarted: () {
        HapticFeedback.heavyImpact();
        onDragStarted();
      },
      onDragEnd: (_) => onDragEnd(),
      onDraggableCanceled: (_, __) => onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.04,
          child: SizedBox(
            width: 244,
            child: _KanbanCard(
              task: task,
              category: category,
              isFeedback: true,
              onTap: () {},
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: _KanbanCard(
        task: task,
        category: category,
        onTap: onTap,
      ),
    );
  }
}

// ── KanbanCard ────────────────────────────────────────────────────────────────

class _KanbanCard extends ConsumerWidget {
  const _KanbanCard({
    required this.task,
    required this.category,
    required this.onTap,
    this.isFeedback = false,
  });

  final Task task;
  final Category? category;
  final VoidCallback onTap;
  final bool isFeedback;

  Color _priorityColor() {
    switch (task.priorityEnum) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prioColor = _priorityColor();
    final catColor = category != null
        ? AppColors.accentFromHex(category!.colorHex)
        : scheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isFeedback
              ? scheme.surface
              : isDark
              ? scheme.surface
              : scheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.onSurface.withOpacity(isFeedback ? 0.15 : 0.07),
          ),
          boxShadow: isFeedback
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority accent bar
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: prioColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: scheme.onSurface.withOpacity(0.4),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (category != null)
                            _Tag(label: category!.name, color: catColor),
                          const Spacer(),
                          if (task.dueDate != null)
                            _DueDateBadge(date: task.dueDate!),
                        ],
                      ),
                      _SubtaskBar(task: task),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}

// ── Due date badge ────────────────────────────────────────────────────────────

class _DueDateBadge extends StatelessWidget {
  const _DueDateBadge({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isOverdue = dateOnly.isBefore(today);
    final isToday = dateOnly.isAtSameMomentAs(today);

    final color = isOverdue
        ? AppColors.priorityHigh
        : isToday
        ? AppColors.priorityMedium
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    final label = isToday
        ? 'Today'
        : isOverdue
        ? 'Overdue'
        : '${_monthAbbr(date.month)} ${date.day}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontSize: 11,
            fontWeight: isOverdue || isToday ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }

  String _monthAbbr(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m - 1];
}

// ── Subtask progress bar ──────────────────────────────────────────────────────

class _SubtaskBar extends ConsumerWidget {
  const _SubtaskBar({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksProvider(task.uuid));
    return subtasksAsync.when(
      data: (subtasks) {
        if (subtasks.isEmpty) return const SizedBox.shrink();
        final done =
            subtasks.where((t) => t.statusEnum == TaskStatus.done).length;
        final progress = done / subtasks.length;
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: scheme.onSurface.withOpacity(0.08),
                    valueColor:
                    const AlwaysStoppedAnimation(AppColors.priorityLow),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$done/${subtasks.length}',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10,
                  color: scheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Empty column state ────────────────────────────────────────────────────────

class _EmptyColState extends StatelessWidget {
  const _EmptyColState({required this.col});
  final _KanbanCol col;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(col.icon, size: 32, color: col.color.withOpacity(0.25)),
            const SizedBox(height: 8),
            Text(
              'No tasks',
              style: AppTypography.labelMedium.copyWith(
                color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}