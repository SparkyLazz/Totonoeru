import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Stats'),
        leading: const BackButton(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Keep going',
              style: AppTextStyles.bodyL.copyWith(color: textPrimary),
            ),
            Text(
              'Stats appear after 3 days',
              style: AppTextStyles.bodyM.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
