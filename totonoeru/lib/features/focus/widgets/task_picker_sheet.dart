// lib/features/focus/widgets/task_picker_sheet.dart
// Task 5.11 — Task picker bottom sheet for Focus screen
//
// FIX (line 32): AppRadius.sheetTop getter doesn't exist.
//   → Use a plain double literal (24.0) directly in BorderRadius.vertical.
// FIX (line 32): const with non-const BorderRadius expression.
//   → Remove const from the Container decoration.
// FIX (line 149): BorderRadius can't be assigned to double.
//   → borderRadius parameter of Container takes a BorderRadius, not a double.
//     The error was in using AppRadius.card (a double) directly where
//     BorderRadius.circular() is needed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/tasks_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/task.dart';

class TaskPickerSheet extends ConsumerWidget {
  const TaskPickerSheet({
    super.key,
    required this.onTaskSelected,
    required this.onClear,
  });

  final ValueChanged<Task> onTaskSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskSectionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        // FIX: use plain double 24.0 — NOT AppRadius.sheetTop (undefined)
        // and NOT const (BorderRadius.vertical is not a const expression)
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24.0),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Focus on…',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () {
                    onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // task list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: tasksAsync.when(
              data: (sections) {
                final allTasks = [
                  ...sections.inProgress,
                  ...sections.pending,
                ];
                if (allTasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No active tasks',
                        style: TextStyle(
                            color: cs.onBackground.withOpacity(0.4)),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.sm,
                  ),
                  shrinkWrap: true,
                  itemCount: allTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) => _TaskPickerRow(
                    task: allTasks[i],
                    onTap: () {
                      onTaskSelected(allTasks[i]);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _TaskPickerRow extends StatelessWidget {
  const _TaskPickerRow({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final priorityColor = task.priorityEnum == TaskPriority.high
        ? AppColors.priorityHigh
        : task.priorityEnum == TaskPriority.medium
        ? AppColors.priorityMedium
        : AppColors.priorityLow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          // FIX: BorderRadius.circular(double) is correct here —
          // do NOT pass AppRadius.card directly; wrap it.
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: cs.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}