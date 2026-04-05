import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/constants/app_spacing.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.outline;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.screenTop),
              Text('集中', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
              const SizedBox(height: 4),
              Text('Focus', style: AppTextStyles.headingL.copyWith(color: textPrimary)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '25:00',
                        style: AppTextStyles.timerXL.copyWith(
                          color: textPrimary,
                          fontSize: 72,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl2),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: accent.accent,
                          minimumSize: const Size(160, 52),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Start Focus',
                          style: AppTextStyles.bodyL.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No sessions yet — start focusing',
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
    );
  }
}
