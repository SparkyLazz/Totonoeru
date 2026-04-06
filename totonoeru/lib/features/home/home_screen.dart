import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/app_fab.dart';
import '../tasks/add_task_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final greetingJP = hour < 12 ? '今朝' : hour < 17 ? '午後' : '夜';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetingJP,
                        style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      settings.userName.isNotEmpty
                          ? '$greeting, ${settings.userName}.'
                          : '$greeting.',
                      style: AppTextStyles.headingL.copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    if (!settings.welcomeCardDismissed)
                      _WelcomeCard(
                        accentColor: accent.accent,
                        accentBg: accent.accentBg,
                        onDismiss: () =>
                            ref.read(settingsProvider.notifier).dismissWelcomeCard(),
                        onAddTask: () => showAddTaskSheet(context),
                      ),

                    const SizedBox(height: AppSpacing.xl),
                    _PlaceholderSection(label: 'Today\'s summary', sublabel: '今日の概要'),
                    const SizedBox(height: AppSpacing.lg),
                    _PlaceholderSection(label: 'Upcoming time blocks', sublabel: '次の予定'),
                    const SizedBox(height: AppSpacing.lg),
                    _PlaceholderSection(label: 'Focus timer', sublabel: '集中タイマー'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: () => showAddTaskSheet(context),
        onAddTimeBlock: () {},
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.accentColor,
    required this.accentBg,
    required this.onDismiss,
    required this.onAddTask,
  });

  final Color accentColor;
  final Color accentBg;
  final VoidCallback onDismiss;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('整える is ready.',
                    style: AppTextStyles.bodyL.copyWith(color: textPrimary)),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 18, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Everything is free, offline, and yours.',
              style: AppTextStyles.bodyM.copyWith(color: textSecondary)),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onAddTask,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add your first task',
                    style: AppTextStyles.bodyM.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({
    required this.label,
    required this.sublabel,
  });

  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.bodyM.copyWith(color: textSecondary)),
            Text(sublabel, style: AppTextStyles.jpXS.copyWith(color: textSecondary)),
          ],
        ),
      ),
    );
  }
}