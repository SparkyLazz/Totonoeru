import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task.dart';

/// Task card for list view. Shows priority bar, title, subtask badge,
/// category tag, priority chip, due date. Handles tap + check tap.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.category,
    this.subtaskCount = 0,
    this.onTap,
    this.onComplete,
  });

  final Task task;

  /// (name, colorHex) — pass null if category not loaded yet
  final ({String name, String colorHex, String nameJp})? category;

  final int subtaskCount;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDone = task.status == 'done';
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.onSurface.withOpacity(0.07),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Priority bar ─────────────────────────────────────────
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: isDone
                      ? scheme.onSurface.withOpacity(0.15)
                      : _priorityColor(task.priority),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // ── Check circle ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onComplete?.call();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.statusDone
                          : Colors.transparent,
                      border: Border.all(
                        color: isDone
                            ? AppColors.statusDone
                            : scheme.onSurface.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + subtask count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDone
                                    ? textSecondary
                                    : textPrimary,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (subtaskCount > 0) ...[
                            const SizedBox(width: 6),
                            _SubtaskBadge(
                              count: subtaskCount,
                              textSecondary: textSecondary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Meta row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (category != null)
                            _CategoryTag(
                              name: category!.name,
                              colorHex: category!.colorHex,
                            ),
                          _PriorityBadge(priority: task.priority),
                          if (task.dueDate != null)
                            _DueDateLabel(
                              dueDate: task.dueDate!,
                              isDone: isDone,
                              textSecondary: textSecondary,
                            ),
                        ],
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

  Color _priorityColor(String priority) => switch (priority) {
    'high' => AppColors.priorityHigh,
    'low' => AppColors.priorityLow,
    _ => AppColors.priorityMedium,
  };
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SubtaskBadge extends StatelessWidget {
  const _SubtaskBadge({required this.count, required this.textSecondary});
  final int count;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.subdirectory_arrow_right_rounded,
              size: 11, color: textSecondary),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: AppTypography.labelSmall.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.name, required this.colorHex});
  final String name;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accentFromHex(colorHex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'high' => ('High', AppColors.priorityHigh),
      'low' => ('Low', AppColors.priorityLow),
      _ => ('Medium', AppColors.priorityMedium),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _DueDateLabel extends StatelessWidget {
  const _DueDateLabel({
    required this.dueDate,
    required this.isDone,
    required this.textSecondary,
  });
  final DateTime dueDate;
  final bool isDone;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = !isDone && due.isBefore(today);
    final isToday = due == today;

    final label = isToday
        ? 'Today'
        : '${_monthAbbr(dueDate.month)} ${dueDate.day}';
    final color = isOverdue
        ? AppColors.priorityHigh
        : isToday
        ? AppColors.priorityMedium
        : textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  String _monthAbbr(int month) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][month];
}