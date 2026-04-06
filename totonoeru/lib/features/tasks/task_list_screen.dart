import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_task_sheet.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/db/collections.dart';
import '../../core/db/task_list_provider.dart';
import '../../core/db/task_repository.dart';
import '../../core/db/category_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../shared/widgets/app_fab.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final counts = ref.watch(taskCountsProvider);
    final grouped = ref.watch(groupedTasksProvider);
    final totalTasks = counts.done + counts.inProgress + counts.pending;
    final isEmpty = totalTasks == 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('タスク一覧',
                      style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
                  const SizedBox(height: 2),
                  Text('Tasks',
                      style: AppTextStyles.headingL.copyWith(color: textPrimary)),
                  const SizedBox(height: 6),

                  if (!isEmpty)
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: '$totalTasks',
                          style: AppTextStyles.bodyM.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' tasks · ',
                          style: AppTextStyles.bodyM.copyWith(color: textSecondary),
                        ),
                        TextSpan(
                          text: '${counts.done}',
                          style: AppTextStyles.bodyM.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' done · ',
                          style: AppTextStyles.bodyM.copyWith(color: textSecondary),
                        ),
                        TextSpan(
                          text: '${counts.inProgress + counts.pending}',
                          style: AppTextStyles.bodyM.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' remaining',
                          style: AppTextStyles.bodyM.copyWith(color: textSecondary),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 14),
                  const _FilterChipRow(),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            Expanded(
              child: isEmpty
                  ? const _EmptyState()
                  : _TaskListBody(grouped: grouped),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: () => showAddTaskSheet(context),
        onAddTimeBlock: () {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP ROW
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipRow extends ConsumerWidget {
  const _FilterChipRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final activeFilter = ref.watch(activeCategoryFilterProvider);
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'All',
            isActive: activeFilter == null,
            activeColor: accent.accent,
            activeBg: accent.accentBg,
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(activeCategoryFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 6),
          ...categoriesAsync.when(
            data: (cats) => cats.map((cat) {
              final color = Color(cat.colorValue);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Chip(
                  label: cat.name,
                  isActive: activeFilter == cat.uuid,
                  activeColor: color,
                  activeBg: color.withValues(alpha: 0.12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(activeCategoryFilterProvider.notifier).state = cat.uuid;
                  },
                ),
              );
            }).toList(),
            loading: () => [],
            error: (_, __) => [],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.transparent : borderColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: isActive ? activeColor : textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK LIST BODY
// ─────────────────────────────────────────────────────────────────────────────

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.grouped});
  final Map<TaskStatus, List<Task>> grouped;

  @override
  Widget build(BuildContext context) {
    final inProgress = grouped[TaskStatus.inProgress] ?? [];
    final pending = grouped[TaskStatus.pending] ?? [];
    final done = grouped[TaskStatus.done] ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 120),
      children: [
        if (inProgress.isNotEmpty) ...[
          _StatusDivider(label: 'In Progress', count: inProgress.length),
          ...inProgress.map((t) => _SwipeableTaskCard(task: t)),
        ],
        if (pending.isNotEmpty) ...[
          _StatusDivider(label: 'Pending', count: pending.length),
          ...pending.map((t) => _SwipeableTaskCard(task: t)),
        ],
        if (done.isNotEmpty) ...[
          _StatusDivider(label: 'Completed', count: done.length),
          ...done.map((t) => _SwipeableTaskCard(task: t, isDimmed: true)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class _StatusDivider extends StatelessWidget {
  const _StatusDivider({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.bodyS.copyWith(
                color: textTertiary,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: AppTextStyles.labelXS.copyWith(color: textTertiary)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 0.5, color: borderColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SWIPEABLE TASK CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeableTaskCard extends ConsumerWidget {
  const _SwipeableTaskCard({required this.task, this.isDimmed = false});
  final Task task;
  final bool isDimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return Dismissible(
      key: ValueKey(task.uuid),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: accent.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          final repo = ref.read(taskRepositoryProvider);
          if (task.status == TaskStatus.done) {
            await repo.uncompletedTask(task.uuid);
          } else {
            await repo.completeTask(task.uuid);
          }
          return false;
        } else {
          HapticFeedback.heavyImpact();
          return true;
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final repo = ref.read(taskRepositoryProvider);
          await repo.deleteTask(task.uuid);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task deleted',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white)),
                backgroundColor: AppColors.darkSurface,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: accent.accent,
                  onPressed: () async => repo.restoreTask(task.uuid),
                ),
              ),
            );
          }
        }
      },
      child: Opacity(
        opacity: isDimmed ? 0.5 : 1.0,
        child: _TaskCard(task: task),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final isDone = task.status == TaskStatus.done;

    final priorityColor = switch (task.priority) {
      TaskPriority.high   => AppColors.priorityHigh,
      TaskPriority.medium => AppColors.priorityMedium,
      TaskPriority.low    => accent.accent,
    };

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskUuid: task.uuid),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: priorityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          final repo = ref.read(taskRepositoryProvider);
                          if (isDone) {
                            await repo.uncompletedTask(task.uuid);
                          } else {
                            await repo.completeTask(task.uuid);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? accent.accent : Colors.transparent,
                            border: Border.all(
                              color: isDone ? accent.accent : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 10, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: AppTextStyles.bodyM.copyWith(
                                color: isDone ? textTertiary : textPrimary,
                                fontWeight: FontWeight.w500,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                decorationColor: textTertiary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _TaskMeta(task: task),
                          ],
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// TASK META
// ─────────────────────────────────────────────────────────────────────────────

class _TaskMeta extends ConsumerWidget {
  const _TaskMeta({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final categoriesAsync = ref.watch(allCategoriesProvider);

    String? categoryName;
    Color? categoryColor;
    categoriesAsync.whenData((cats) {
      final cat = cats.where((c) => c.uuid == task.categoryId).firstOrNull;
      if (cat != null) {
        categoryName = cat.name;
        categoryColor = Color(cat.colorValue);
      }
    });

    final (priorityLabel, priorityBg, priorityFg) = switch (task.priority) {
      TaskPriority.high   => ('High',   const Color(0xFFFCEBEB), AppColors.priorityHigh),
      TaskPriority.medium => ('Medium', const Color(0xFFFAEEDA), AppColors.priorityMedium),
      TaskPriority.low    => ('Low',    accent.accentBg,         accent.accent),
    };

    String? dueLabel;
    bool isDueSoon = false;
    if (task.dueDate != null) {
      final now = DateTime.now();
      final due = task.dueDate!;
      final diff = due.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff == 0) { dueLabel = 'Due today'; isDueSoon = true; }
      else if (diff == 1) { dueLabel = 'Due tomorrow'; isDueSoon = true; }
      else if (diff < 0) { dueLabel = 'Overdue'; isDueSoon = true; }
      else {
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        dueLabel = 'Due ${months[due.month - 1]} ${due.day}';
      }
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (categoryName != null && categoryColor != null)
          _Badge(
            label: categoryName!,
            bg: categoryColor!.withValues(alpha: 0.12),
            fg: categoryColor!,
          ),
        _Badge(label: priorityLabel, bg: priorityBg, fg: priorityFg),
        if (dueLabel != null)
          Text(dueLabel,
              style: AppTextStyles.labelXS.copyWith(
                color: isDueSoon ? AppColors.priorityHigh : textTertiary,
              )),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.labelXS.copyWith(color: fg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.accentBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_box_outlined, size: 30, color: accent.accent),
            ),
            const SizedBox(height: 20),
            Text('No tasks yet',
                style: AppTextStyles.bodyL.copyWith(
                    color: textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Start fresh — add your first task and let Totonoeru help you stay on track.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM.copyWith(color: textTertiary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}