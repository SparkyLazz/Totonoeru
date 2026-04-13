// lib/features/schedule/schedule_empty_state.dart
//
// Task 3.22 — Schedule empty state (no blocks for selected day)
// Used inside HourlyTimeline when blocks list is empty.

import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key, this.onAddBlock});
  final VoidCallback? onAddBlock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textSecondary = scheme.onSurface.withOpacity(0.4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustrated icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 32,
                color: accent.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nothing scheduled',
              style: AppTypography.headingSmall.copyWith(
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A free day ahead — tap + to add a time block.',
              style: AppTypography.bodySmall.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '予定なし — ブロックを追加しよう',
              style: AppTypography.jpLight.copyWith(
                color: textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddBlock != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddBlock,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add time block'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}