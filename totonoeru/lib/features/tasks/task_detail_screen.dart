import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/database_service.dart';
import '../../shared/widgets/app_toast.dart';
import 'add_task_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(singleTaskProvider(taskId));

    return taskAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('Task not found')),
          );
        }
        return _TaskDetailBody(task: task);
      },
    );
  }
}

class _TaskDetailBody extends ConsumerWidget {
  const _TaskDetailBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final accent = scheme.primary;
    final subtasks = ref.watch(subtasksProvider(task.uuid));

    // Load category
    final catFuture = DatabaseService.instance.isar.categorys
        .getByUuid(task.categoryId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTaskSheet(editTask: task),
              );
            },
          ),
          // Delete button (2.20)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20,
                color: AppColors.priorityHigh),
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
        title: const Text(
          'Task Detail',
          style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Priority bar + Title ────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _priorityColor(task.priority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: AppTypography.headingMedium.copyWith(
                            color: textPrimary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      // Complete toggle
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          TaskRepository.instance.completeTask(task);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted
                                ? AppColors.statusDone
                                : Colors.transparent,
                            border: Border.all(
                              color: task.isCompleted
                                  ? AppColors.statusDone
                                  : scheme.onSurface.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // ── Meta chips ──────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                        icon: Icons.flag_outlined,
                        label: _priorityLabel(task.priority),
                        color: _priorityColor(task.priority),
                      ),
                      if (task.dueDate != null)
                        _MetaChip(
                          icon: Icons.calendar_today_outlined,
                          label: _formatDate(task.dueDate!),
                          color: accent,
                        ),
                      if (task.reminderTime != null)
                        _MetaChip(
                          icon: Icons.notifications_outlined,
                          label: _formatDate(task.reminderTime!),
                          color: scheme.onSurface.withOpacity(0.5),
                        ),
                    ],
                  ),

                  // ── Notes ───────────────────────────────────────────
                  if (task.notes != null && task.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.base),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.notes!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],

                  // ── Linked time block (2.19) ────────────────────────
                  if (task.scheduleBlockId != null) ...[
                    const SizedBox(height: AppSpacing.base),
                    _LinkedBlockInfo(blockId: task.scheduleBlockId!),
                  ],

                  // ── Subtasks (2.18) ─────────────────────────────────
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text(
                        'SUBTASKS',
                        style: AppTypography.labelSmall.copyWith(
                          color: textPrimary.withOpacity(0.4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              AddTaskSheet(parentTaskId: task.uuid),
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 18, color: accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  subtasks.when(
                    data: (subs) => subs.isEmpty
                        ? Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No subtasks',
                        style: AppTypography.bodySmall.copyWith(
                          color: textPrimary.withOpacity(0.35),
                        ),
                      ),
                    )
                        : Column(
                      children: subs
                          .map((st) => _SubtaskCheckRow(
                        task: st,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          TaskRepository.instance
                              .completeTask(st);
                        },
                      ))
                          .toList(),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String p) => switch (p) {
    'high' => AppColors.priorityHigh,
    'low' => AppColors.priorityLow,
    _ => AppColors.priorityMedium,
  };

  String _priorityLabel(String p) =>
      p[0].toUpperCase() + p.substring(1);

  String _formatDate(DateTime dt) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[dt.month]} ${dt.day}';
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task',
            style: TextStyle(fontFamily: 'DMSans')),
        content: const Text('This task will be deleted. This cannot be undone.',
            style: TextStyle(fontFamily: 'DMSans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'DMSans')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    fontFamily: 'DMSans',
                    color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await TaskRepository.instance.softDeleteTask(task);
      if (context.mounted) {
        AppToast.show(context, 'Task deleted');
        Navigator.pop(context);
      }
    }
  }
}

// ── Subtask check row ─────────────────────────────────────────────────────────

class _SubtaskCheckRow extends StatelessWidget {
  const _SubtaskCheckRow({required this.task, required this.onToggle});
  final Task task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.statusDone : Colors.transparent,
                border: Border.all(
                  color: isDone
                      ? AppColors.statusDone
                      : scheme.onSurface.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: AppTypography.bodySmall.copyWith(
                color: isDone
                    ? scheme.onSurface.withOpacity(0.4)
                    : scheme.onSurface,
                decoration:
                isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Linked block info (2.19) ──────────────────────────────────────────────────

class _LinkedBlockInfo extends StatelessWidget {
  const _LinkedBlockInfo({required this.blockId});
  final String blockId;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            'Linked to a time block',
            style: AppTypography.bodySmall.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}