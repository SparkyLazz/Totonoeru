import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/app_fab.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

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
              Text('今日の予定', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
              const SizedBox(height: 4),
              Text('Schedule', style: AppTextStyles.headingL.copyWith(color: textPrimary)),
              const SizedBox(height: AppSpacing.xl2),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 48, color: textSecondary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Nothing scheduled',
                        style: AppTextStyles.bodyL.copyWith(color: textSecondary),
                      ),
                      Text(
                        'Tap + to add a time block',
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
