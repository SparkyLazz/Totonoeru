import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/app_fab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TASK LIST SCREEN — Week 1 shell
// Full implementation: Week 2 (task CRUD, list + kanban, swipe interactions)
// ─────────────────────────────────────────────────────────────────────────────

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.outline;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.screenTop),
              Text('タスク一覧', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
              const SizedBox(height: 4),
              Text('Tasks', style: AppTextStyles.headingL.copyWith(color: textPrimary)),
              const SizedBox(height: AppSpacing.xl2),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_box_outlined, size: 48, color: textSecondary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No tasks yet',
                        style: AppTextStyles.bodyL.copyWith(color: textSecondary),
                      ),
                      Text(
                        'Add your first task',
                        style: AppTextStyles.bodyM.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: () {},
        onAddTimeBlock: () {},
      ),
    );
  }
}
