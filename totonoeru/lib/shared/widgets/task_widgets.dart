import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRIORITY BADGE
// High / Medium / Low — colored dot + text label
// ─────────────────────────────────────────────────────────────────────────────

enum TaskPriority { high, medium, low }

extension TaskPriorityExt on TaskPriority {
  String get label => switch (this) {
    TaskPriority.high   => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low    => 'Low',
  };
  Color get color => switch (this) {
    TaskPriority.high   => AppColors.priorityHigh,
    TaskPriority.medium => AppColors.priorityMedium,
    TaskPriority.low    => AppColors.priorityLow,
  };
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: AppTextStyles.bodyS.copyWith(
              color: priority.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY TAG
// Colored pill with category name
// ─────────────────────────────────────────────────────────────────────────────

class CategoryTag extends StatelessWidget {
  const CategoryTag({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyS.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// e.g. "In Progress" / "Pending" divider in task list
// ─────────────────────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.count,
  });

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelXS.copyWith(
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: textSecondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelXS.copyWith(color: textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
