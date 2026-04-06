import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/category_repository.dart';
import '../../core/db/collections.dart';
import '../../core/db/task_repository.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'add_task_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TASK DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskUuid});
  final String taskUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    // Watch the task live from Isar
    final taskAsync = ref.watch(_taskByUuidProvider(taskUuid));

    return taskAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Scaffold(
        body: Center(child: Text('Error loading task')),
      ),
      data: (task) {
        if (task == null) {
          // Task was deleted — go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final isDone = task.status == TaskStatus.done;
        final priorityColor = switch (task.priority) {
          TaskPriority.high   => AppColors.priorityHigh,
          TaskPriority.medium => AppColors.priorityMedium,
          TaskPriority.low    => accent.accent,
        };

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top nav ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      _CircleButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.of(context).pop(),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        iconColor: textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text('Tasks',
                          style: AppTextStyles.bodyS
                              .copyWith(color: textTertiary)),
                      const Spacer(),
                      // Delete button
                      _CircleButton(
                        icon: Icons.delete_outline_rounded,
                        onTap: () => _confirmDelete(context, ref, task),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        iconColor: AppColors.priorityHigh,
                      ),
                    ],
                  ),
                ),

                // ── Priority bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Scrollable content ────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                    children: [
                      // Title + check
                      Row(
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
                              duration: const Duration(milliseconds: 220),
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(top: 2, right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? accent.accent : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? accent.accent : borderColor,
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(Icons.check,
                                  size: 13, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTextStyles.headingM.copyWith(
                                color: isDone ? textTertiary : textPrimary,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tags row
                      _TagsRow(task: task),
                      const SizedBox(height: 14),

                      // Meta cards grid
                      _MetaGrid(task: task),
                      const SizedBox(height: 20),

                      // Notes section
                      if (task.notes != null && task.notes!.isNotEmpty) ...[
                        _SectionDivider(label: 'NOTES', textTertiary: textTertiary, borderColor: borderColor),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            border: Border.all(color: borderColor, width: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.notes!,
                            style: AppTextStyles.bodyM.copyWith(
                              color: textSecondary,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Subtasks section
                      _SubtasksSection(parentTask: task),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom action bar ─────────────────────────────────────────────
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: borderColor, width: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            child: Row(
              children: [
                // Complete button
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        final repo = ref.read(taskRepositoryProvider);
                        if (isDone) {
                          await repo.uncompletedTask(task.uuid);
                        } else {
                          await repo.completeTask(task.uuid);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone
                            ? (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2)
                            : accent.accent,
                        foregroundColor: isDone ? textSecondary : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isDone ? Icons.refresh_rounded : Icons.check_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isDone ? 'Mark Incomplete' : 'Mark Complete',
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDone ? textSecondary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Edit button
                _CircleButton(
                  icon: Icons.edit_outlined,
                  size: 46,
                  onTap: () => showAddTaskSheet(context, existingTask: task),
                  cardBg: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderColor: borderColor,
                  iconColor: textSecondary,
                  radius: 12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await ref.read(taskRepositoryProvider).deleteTask(task.uuid);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE TASK PROVIDER — watches a single task by uuid
// ─────────────────────────────────────────────────────────────────────────────

final _taskByUuidProvider =
StreamProvider.family<Task?, String>((ref, uuid) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTaskByUuid(uuid);
});

// ─────────────────────────────────────────────────────────────────────────────
// TAGS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _TagsRow extends ConsumerWidget {
  const _TagsRow({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (categoryName != null && categoryColor != null)
          _Tag(
            label: categoryName!,
            bg: categoryColor!.withValues(alpha: 0.12),
            fg: categoryColor!,
          ),
        _Tag(label: priorityLabel, bg: priorityBg, fg: priorityFg),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: AppTextStyles.labelXS.copyWith(
              color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// META GRID — due date, created at
// ─────────────────────────────────────────────────────────────────────────────

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.task});
  final Task task;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff < 0) return 'Overdue';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  bool _isUrgent(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(today).inDays <= 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      children: [
        // Due date
        Expanded(
          child: _MetaCard(
            iconBg: const Color(0xFFFCEBEB),
            iconColor: AppColors.priorityHigh,
            icon: Icons.calendar_today_outlined,
            label: 'DUE DATE',
            value: task.dueDate != null ? _formatDate(task.dueDate!) : 'None',
            valueColor: task.dueDate != null && _isUrgent(task.dueDate!)
                ? AppColors.priorityHigh
                : textPrimary,
            cardBg: cardBg,
            borderColor: borderColor,
            textTertiary: textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        // Created
        Expanded(
          child: _MetaCard(
            iconBg: const Color(0xFFE1F5EE),
            iconColor: AppColors.accentTeal,
            icon: Icons.add_circle_outline_rounded,
            label: 'CREATED',
            value: _formatCreated(task.createdAt),
            valueColor: textPrimary,
            cardBg: cardBg,
            borderColor: borderColor,
            textTertiary: textTertiary,
          ),
        ),
      ],
    );
  }

  String _formatCreated(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.cardBg,
    required this.borderColor,
    required this.textTertiary,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final Color cardBg;
  final Color borderColor;
  final Color textTertiary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.labelXS.copyWith(
                  color: textTertiary, letterSpacing: 0.6)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodyS.copyWith(
                  color: valueColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBTASKS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SubtasksSection extends ConsumerStatefulWidget {
  const _SubtasksSection({required this.parentTask});
  final Task parentTask;

  @override
  ConsumerState<_SubtasksSection> createState() => _SubtasksSectionState();
}

class _SubtasksSectionState extends ConsumerState<_SubtasksSection> {
  final _controller = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addSubtask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _isAdding = false);
      return;
    }
    await ref.read(taskRepositoryProvider).createTask(
      title: title,
      parentUuid: widget.parentTask.uuid,
      categoryId: widget.parentTask.categoryId,
    );
    _controller.clear();
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    final subtasksAsync = ref.watch(_subtasksProvider(widget.parentTask.uuid));

    return subtasksAsync.when(
      data: (subtasks) {
        final doneCount = subtasks.where((s) => s.status == TaskStatus.done).length;
        final total = subtasks.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionDivider(
              label: 'SUBTASKS',
              count: total > 0 ? '$doneCount/$total' : null,
              textTertiary: textTertiary,
              borderColor: borderColor,
            ),

            // Progress bar
            if (total > 0) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: total > 0 ? doneCount / total : 0,
                          backgroundColor: surfaceVariant,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(accent.accent),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$doneCount/$total',
                      style: AppTextStyles.monoM.copyWith(
                          color: accent.accent,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Subtask items
            ...subtasks.map((sub) => _SubtaskItem(
              subtask: sub,
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textTertiary: textTertiary,
            )),

            // Add subtask row
            if (_isAdding)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: accent.accent, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: AppTextStyles.bodyM.copyWith(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Subtask title…',
                          hintStyle: AppTextStyles.bodyM
                              .copyWith(color: textTertiary),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addSubtask,
                      child: Icon(Icons.check_rounded,
                          size: 18, color: accent.accent),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _isAdding = true),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: borderColor,
                        width: 1.5,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded,
                          size: 14, color: textTertiary),
                      const SizedBox(width: 8),
                      Text('Add subtask',
                          style: AppTextStyles.bodyS
                              .copyWith(color: textTertiary)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SubtaskItem extends ConsumerWidget {
  const _SubtaskItem({
    required this.subtask,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textTertiary,
  });

  final Task subtask;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textTertiary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final isDone = subtask.status == TaskStatus.done;

    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final repo = ref.read(taskRepositoryProvider);
                if (isDone) {
                  await repo.uncompletedTask(subtask.uuid);
                } else {
                  await repo.completeTask(subtask.uuid);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
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
              child: Text(
                subtask.title,
                style: AppTextStyles.bodyM.copyWith(
                  color: isDone ? textTertiary : textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({
    required this.label,
    required this.textTertiary,
    required this.borderColor,
    this.count,
  });
  final String label;
  final String? count;
  final Color textTertiary;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.labelXS.copyWith(
                color: textTertiary, letterSpacing: 0.8)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(count!,
                style: AppTextStyles.labelXS.copyWith(color: textTertiary)),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(child: Container(height: 0.5, color: borderColor)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CIRCLE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.cardBg,
    required this.borderColor,
    required this.iconColor,
    this.size = 32,
    this.radius,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color cardBg;
  final Color borderColor;
  final Color iconColor;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(radius ?? size / 2),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final _subtasksProvider =
FutureProvider.family<List<Task>, String>((ref, parentUuid) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getSubtasks(parentUuid);
});