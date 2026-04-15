// lib/features/schedule/link_task_sheet.dart
//
// Task 4.21 — LinkTaskSheet: pick a task to link to a time block
// Shown from AddTimeBlockSheet / TimeBlockDetailSheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task.dart';
import '../../data/models/time_block.dart';
import '../../data/services/link_service.dart';
import '../../shared/widgets/app_toast.dart';

class LinkTaskSheet extends ConsumerStatefulWidget {
  const LinkTaskSheet({super.key, required this.block});
  final TimeBlock block;

  @override
  ConsumerState<LinkTaskSheet> createState() => _LinkTaskSheetState();
}

class _LinkTaskSheetState extends ConsumerState<LinkTaskSheet> {
  String _search = '';
  bool _linking = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    final tasksAsync = ref.watch(tasksProvider);

    // Currently linked task uuid
    final linkedTaskId = widget.block.taskId;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link a Task',
                      style: AppTypography.headingSmall.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'タスクをリンク',
                      style: AppTypography.jpLight.copyWith(
                        color: textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Unlink button if already linked
                if (linkedTaskId != null)
                  TextButton.icon(
                    onPressed: _unlinking,
                    icon: const Icon(Icons.link_off_rounded, size: 14),
                    label: const Text('Unlink'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.priorityHigh,
                      textStyle: AppTypography.labelSmall,
                    ),
                  ),
              ],
            ),
          ),

          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: textSecondary,
                ),
                isDense: true,
                filled: true,
                fillColor: scheme.onSurface.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),

          const Divider(height: 1),

          // Task list
          Expanded(
            child: tasksAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tasks) {
                final active = tasks.where((t) =>
                t.status != 'done' &&
                    !t.isDeleted &&
                    t.parentTaskId == null);

                final filtered = _search.isEmpty
                    ? active.toList()
                    : active
                    .where((t) =>
                    t.title.toLowerCase().contains(_search))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _search.isEmpty
                          ? 'No active tasks'
                          : 'No tasks matching "$_search"',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final task = filtered[i];
                    final isLinked = task.uuid == linkedTaskId;
                    return _TaskRow(
                      task: task,
                      isLinked: isLinked,
                      accent: accent,
                      scheme: scheme,
                      onTap: () => _linkTask(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _linkTask(Task task) async {
    HapticFeedback.lightImpact();
    setState(() => _linking = true);
    try {
      await LinkService.linkTaskToBlock(task, widget.block);
      if (mounted) {
        Navigator.pop(context);
        AppToast.show(context, 'Linked to "${task.title}"');
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  Future<void> _unlinking() async {
    if (widget.block.taskId == null) return;
    HapticFeedback.mediumImpact();
    final task = await LinkService.getTaskForBlock(widget.block);
    if (task == null) return;
    await LinkService.unlinkTaskFromBlock(task, widget.block);
    if (mounted) {
      Navigator.pop(context);
      AppToast.show(context, 'Link removed');
    }
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isLinked,
    required this.accent,
    required this.scheme,
    required this.onTap,
  });

  final Task task;
  final bool isLinked;
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onTap;

  Color get _prioColor => switch (task.priority) {
    'high' => AppColors.priorityHigh,
    'low' => AppColors.priorityLow,
    _ => AppColors.priorityMedium,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isLinked
              ? accent.withOpacity(0.06)
              : scheme.onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLinked
                ? accent.withOpacity(0.3)
                : scheme.onSurface.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: _prioColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLinked)
              Icon(Icons.link_rounded, size: 16, color: accent)
            else
              Icon(
                Icons.add_link_rounded,
                size: 16,
                color: scheme.onSurface.withOpacity(0.25),
              ),
          ],
        ),
      ),
    );
  }
}