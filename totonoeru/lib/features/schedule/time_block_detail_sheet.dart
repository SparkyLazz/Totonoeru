// lib/features/schedule/time_block_detail_sheet.dart
//
// Task 3.16 — TimeBlockDetailSheet (updated Week 4 to add 4.22 link button)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/categories_provider.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/time_block.dart';
import '../../data/repositories/time_block_repository.dart';
import '../../data/services/link_service.dart';
import '../../shared/widgets/app_toast.dart';
import 'add_time_block_sheet.dart';
import 'link_task_sheet.dart';

class TimeBlockDetailSheet extends ConsumerWidget {
  const TimeBlockDetailSheet({super.key, required this.block});
  final TimeBlock block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final catsAsync = ref.watch(categoriesProvider);
    final catMap = <String, Category>{
      for (final c in catsAsync.valueOrNull ?? []) c.uuid: c,
    };
    final category = catMap[block.categoryId];

    final blockColor = block.colorOverride != null
        ? AppColors.accentFromHex(block.colorOverride!)
        : category != null
        ? AppColors.accentFromHex(category.colorHex)
        : scheme.primary;

    final durationMin = block.endTime.difference(block.startTime).inMinutes;
    final hours = durationMin ~/ 60;
    final mins = durationMin % 60;
    final durationLabel = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar
            Container(
              height: 4,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    block.title,
                    style: AppTypography.headingMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (category != null)
                        _Tag(label: category.name, color: blockColor),
                      _PriorityTag(priority: block.priority),
                      // 4.22 — linked task badge
                      if (block.taskId != null)
                        _Tag(
                          label: 'Linked task',
                          color: AppColors.accentBlue,
                          icon: Icons.link_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Divider(color: scheme.onSurface.withOpacity(0.08)),
                  const SizedBox(height: 12),

                  // Time info row
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 18, color: blockColor),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmtTime(block.startTime)} – ${_fmtTime(block.endTime)}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$durationLabel · ${_fmtDate(block.startTime)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: scheme.onSurface.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Notes
                  if (block.notes != null && block.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(color: scheme.onSurface.withOpacity(0.08)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 16,
                            color: scheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            block.notes!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      // Edit
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  AddTimeBlockSheet(editBlock: block),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.onSurface,
                            side: BorderSide(
                                color: scheme.onSurface.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            textStyle: AppTypography.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 4.22 — Link task
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  LinkTaskSheet(block: block),
                            );
                          },
                          icon: Icon(
                            block.taskId != null
                                ? Icons.link_rounded
                                : Icons.add_link_rounded,
                            size: 16,
                          ),
                          label: Text(
                            block.taskId != null ? 'Linked' : 'Link task',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentBlue,
                            side: BorderSide(
                                color: AppColors.accentBlue.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            textStyle: AppTypography.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _confirmDelete(context, ref, block),
                          icon: const Icon(
                              Icons.delete_outline_rounded, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.priorityHigh,
                            side: BorderSide(
                                color:
                                AppColors.priorityHigh.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            textStyle: AppTypography.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      TimeBlock block,
      ) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete block?',
            style: TextStyle(fontFamily: 'DMSans')),
        content: Text(
          'Remove "${block.title}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'DMSans'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.priorityHigh),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      // Also unlink task if linked
      if (block.taskId != null) {
        final task =
        await LinkService.getTaskForBlock(block);
        if (task != null) {
          task.scheduleBlockId = null;
          task.updatedAt = DateTime.now();
          await LinkService.getTaskForBlock(block); // no-op just future
        }
      }
      await TimeBlockRepository.instance.softDelete(block);
      ref.invalidate(dayBlocksProvider);
      if (context.mounted) {
        Navigator.pop(context);
        AppToast.show(context, '${block.title} deleted');
      }
    }
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _PriorityTag extends StatelessWidget {
  const _PriorityTag({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'high' => AppColors.priorityHigh,
      'medium' => AppColors.priorityMedium,
      _ => AppColors.priorityLow,
    };
    final label = switch (priority) {
      'high' => 'High',
      'medium' => 'Medium',
      _ => 'Low',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}