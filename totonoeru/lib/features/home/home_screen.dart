// lib/features/home/home_screen.dart
//
// Week 4 — Full Home Dashboard
// 4.11  Greeting + profile name + date
// 4.12  Streak counter card
// 4.13  Today's task summary chips (done / in progress / pending)
// 4.14  Progress ring (task completion %)
// 4.15  Upcoming time blocks list (next 3)
// 4.16  Empty states for blocks and tasks
// 4.17  Quick-add FAB (wired)
// 4.18  Weekly focus stat chip
// 4.19  "Add your first task/block" CTAs when empty

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/providers/home_providers.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/time_block.dart';
import '../../shared/widgets/app_fab.dart';
import '../tasks/add_task_sheet.dart';
import '../schedule/add_time_block_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final greetingJp = hour < 12
        ? 'おはようございます'
        : hour < 17
        ? 'こんにちは'
        : 'こんばんは';

    void openAddTask() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddTaskSheet(),
      );
    }

    void openAddTimeBlock() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddTimeBlockSheet(),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 4.11 Greeting ───────────────────────────────────
                    Text(
                      greetingJp,
                      style: AppTypography.jpLight.copyWith(
                        color: textSecondary,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.isNotEmpty
                          ? '$greeting, $name.'
                          : '$greeting.',
                      style: AppTypography.displayMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(),
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── 4.12–4.14 Stats row ─────────────────────────────
                    _StatsRow(accent: accent, scheme: scheme),

                    const SizedBox(height: 20),

                    // ── 4.15–4.16 Upcoming blocks ───────────────────────
                    _SectionHeader(
                      label: 'Upcoming',
                      jpLabel: '次のブロック',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      actionLabel: 'Schedule',
                      onAction: () => context.go(AppRoutes.schedule),
                    ),
                    const SizedBox(height: 10),
                    _UpcomingBlocksSection(
                      accent: accent,
                      scheme: scheme,
                      onAddBlock: openAddTimeBlock,
                    ),

                    const SizedBox(height: 24),

                    // ── 4.13 Today's tasks ──────────────────────────────
                    _SectionHeader(
                      label: "Today's tasks",
                      jpLabel: '今日のタスク',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      actionLabel: 'All tasks',
                      onAction: () => context.go(AppRoutes.tasks),
                    ),
                    const SizedBox(height: 10),
                    _TodayTasksSection(
                      accent: accent,
                      scheme: scheme,
                      onAddTask: openAddTask,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: openAddTask,
        onAddTimeBlock: openAddTimeBlock,
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ── Stats row (streak + tasks done + focus) ────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.accent, required this.scheme});
  final Color accent;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final summaryAsync = ref.watch(todayTaskSummaryProvider);
    final focusAsync = ref.watch(weeklyFocusProvider);

    final streak = streakAsync.valueOrNull ?? 0;
    final summary = summaryAsync.valueOrNull;
    final focusMins = focusAsync.valueOrNull ?? 0;

    return Row(
      children: [
        // Streak card (4.12)
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.priorityHigh,
            value: '$streak',
            label: 'day streak',
            labelJp: 'ストリーク',
            scheme: scheme,
          ),
        ),
        const SizedBox(width: 10),
        // Progress card (4.14)
        Expanded(
          child: _ProgressCard(
            done: summary?.done ?? 0,
            total: summary?.total ?? 0,
            accent: accent,
            scheme: scheme,
          ),
        ),
        const SizedBox(width: 10),
        // Focus card (4.18)
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.accentBlue,
            value: focusMins > 0
                ? (focusMins >= 60
                ? '${focusMins ~/ 60}h'
                : '${focusMins}m')
                : '—',
            label: 'focus this week',
            labelJp: '集中時間',
            scheme: scheme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.labelJp,
    required this.scheme,
  });

  final IconData icon;
  final Color iconColor;
  final String value, label, labelJp;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: scheme.onSurface.withOpacity(0.45),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            labelJp,
            style: AppTypography.jpLight.copyWith(
              color: scheme.onSurface.withOpacity(0.3),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.done,
    required this.total,
    required this.accent,
    required this.scheme,
  });

  final int done, total;
  final Color accent;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini ring
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 3,
              backgroundColor: accent.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$done/$total',
            style: AppTypography.headingMedium.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'tasks done',
            style: AppTypography.labelSmall.copyWith(
              color: scheme.onSurface.withOpacity(0.45),
              fontSize: 10,
            ),
          ),
          Text(
            'タスク完了',
            style: AppTypography.jpLight.copyWith(
              color: scheme.onSurface.withOpacity(0.3),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming blocks (4.15–4.16) ────────────────────────────────────────────────

class _UpcomingBlocksSection extends ConsumerWidget {
  const _UpcomingBlocksSection({
    required this.accent,
    required this.scheme,
    required this.onAddBlock,
  });
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onAddBlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(upcomingBlocksProvider);

    return blocksAsync.when(
      loading: () => _LoadingPlaceholder(scheme: scheme),
      error: (_, __) => const SizedBox.shrink(),
      data: (blocks) {
        if (blocks.isEmpty) {
          return _BlockEmptyState(
            accent: accent,
            scheme: scheme,
            onAdd: onAddBlock,
          );
        }
        return Column(
          children: blocks.map((b) => _BlockRow(
            block: b,
            scheme: scheme,
          )).toList(),
        );
      },
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({required this.block, required this.scheme});
  final TimeBlock block;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final accent = scheme.primary;
    final color = block.colorOverride != null
        ? AppColors.accentFromHex(block.colorOverride!)
        : accent;

    final now = DateTime.now();
    final isNow = block.startTime.isBefore(now) && block.endTime.isAfter(now);
    final startLabel =
        '${block.startTime.hour.toString().padLeft(2, '0')}:${block.startTime.minute.toString().padLeft(2, '0')}';
    final endLabel =
        '${block.endTime.hour.toString().padLeft(2, '0')}:${block.endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNow
              ? color.withOpacity(0.4)
              : scheme.onSurface.withOpacity(0.07),
          width: isNow ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isNow)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NOW',
                          style: AppTypography.labelSmall.copyWith(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        block.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$startLabel – $endLabel',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.onSurface.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockEmptyState extends StatelessWidget {
  const _BlockEmptyState({
    required this.accent,
    required this.scheme,
    required this.onAdd,
  });
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 20, color: scheme.onSurface.withOpacity(0.25)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No upcoming blocks today',
              style: AppTypography.bodySmall.copyWith(
                color: scheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Add',
                style: AppTypography.labelSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today's tasks section (4.13 + 4.19) ───────────────────────────────────────

class _TodayTasksSection extends ConsumerWidget {
  const _TodayTasksSection({
    required this.accent,
    required this.scheme,
    required this.onAddTask,
  });
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayTaskSummaryProvider);

    return summaryAsync.when(
      loading: () => _LoadingPlaceholder(scheme: scheme),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        if (summary.total == 0) {
          return _TaskEmptyState(
            accent: accent,
            scheme: scheme,
            onAdd: onAddTask,
          );
        }
        return _TaskSummaryCard(
          summary: summary,
          accent: accent,
          scheme: scheme,
        );
      },
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({
    required this.summary,
    required this.accent,
    required this.scheme,
  });
  final TodayTaskSummary summary;
  final Color accent;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.completionRate,
              minHeight: 5,
              backgroundColor: accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 14),
          // Chips row
          Row(
            children: [
              _TaskChip(
                count: summary.done,
                label: 'Done',
                color: AppColors.statusDone,
              ),
              const SizedBox(width: 8),
              _TaskChip(
                count: summary.inProgress,
                label: 'In progress',
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: 8),
              _TaskChip(
                count: summary.pending,
                label: 'Pending',
                color: scheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({
    required this.count,
    required this.label,
    required this.color,
  });
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTypography.headingSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskEmptyState extends StatelessWidget {
  const _TaskEmptyState({
    required this.accent,
    required this.scheme,
    required this.onAdd,
  });
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 20, color: accent.withOpacity(0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your day',
                  style: AppTypography.labelMedium.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Add your first task for today',
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Add task',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.jpLabel,
    required this.textPrimary,
    required this.textSecondary,
    this.actionLabel,
    this.onAction,
  });
  final String label, jpLabel;
  final Color textPrimary, textSecondary;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.headingSmall.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              jpLabel,
              style: AppTypography.jpLight.copyWith(
                color: textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAction!();
            },
            child: Text(
              actionLabel!,
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Loading placeholder ────────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: scheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}