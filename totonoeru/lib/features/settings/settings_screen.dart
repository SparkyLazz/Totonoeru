import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/providers/settings_provider.dart';
import '../stats/stats_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          children: [
            const SizedBox(height: AppSpacing.screenTop),
            Text('設定', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
            const SizedBox(height: 4),
            Text('Settings', style: AppTextStyles.headingL.copyWith(color: textPrimary)),
            const SizedBox(height: AppSpacing.xl2),

            _SectionLabel(label: 'Profile', textSecondary: textSecondary),
            _SettingsCard(cardBg: cardBg, borderColor: borderColor, children: [
              _InfoRow(
                label: 'Name',
                value: settings.userName.isNotEmpty ? settings.userName : 'Not set',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel(label: 'Appearance', textSecondary: textSecondary),
            _SettingsCard(cardBg: cardBg, borderColor: borderColor, children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme', style: AppTextStyles.bodyL.copyWith(color: textPrimary)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: ThemeMode.values.map((mode) {
                        final label = mode.name[0].toUpperCase() + mode.name.substring(1);
                        final isSelected = settings.themeMode == mode;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => ref
                                .read(settingsProvider.notifier)
                                .setThemeMode(mode),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accent Color',
                        style: AppTextStyles.bodyL.copyWith(color: textPrimary)),
                    const SizedBox(height: 4),
                    Text('アクセントカラー',
                        style: AppTextStyles.jpXS.copyWith(color: textSecondary)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: AppColors.accentPresets.map((color) {
                        final isSelected =
                            settings.accentColor.toARGB32() == color.toARGB32();
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(settingsProvider.notifier)
                                .setAccentColor(color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: textPrimary, width: 2.5)
                                    : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel(label: 'Data', textSecondary: textSecondary),
            _SettingsCard(cardBg: cardBg, borderColor: borderColor, children: [
              _TappableRow(
                icon: Icons.bar_chart_rounded,
                label: 'Productivity Stats',
                sublabel: '生産性統計',
                accentColor: accent.accent,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel(label: 'About', textSecondary: textSecondary),
            _SettingsCard(cardBg: cardBg, borderColor: borderColor, children: [
              _InfoRow(
                label: 'Version',
                value: '1.0.0',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              Divider(height: 1, color: borderColor),
              _InfoRow(
                label: 'Storage',
                value: '100% Offline · No tracking',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textSecondary});
  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelXS.copyWith(
          color: textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
    required this.cardBg,
    required this.borderColor,
  });
  final List<Widget> children;
  final Color cardBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyL.copyWith(color: textPrimary)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyM.copyWith(color: textSecondary)),
        ],
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  const _TappableRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyL.copyWith(color: textPrimary)),
                Text(sublabel, style: AppTextStyles.jpXS.copyWith(color: textSecondary)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}