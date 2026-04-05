import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/providers/settings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING SCREEN — 3 steps
// Step 1: Name entry
// Step 2: Accent color selection
// Step 3: "Let's go" — completes onboarding, nav to Home
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  Color _selectedAccent = AppColors.accentTeal;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // Save accent color first
    await ref.read(settingsProvider.notifier).setAccentColor(_selectedAccent);
    // Complete onboarding with name
    await ref.read(settingsProvider.notifier).completeOnboarding(
      _nameController.text.trim(),
    );
    // Router redirect handles navigation to Home automatically
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.outline;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            const SizedBox(height: AppSpacing.xl2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? accent.accent
                        : accent.accentBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xl3),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _NamePage(
                    controller: _nameController,
                    accentColor: accent.accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _AccentPage(
                    selectedAccent: _selectedAccent,
                    onSelect: (c) => setState(() => _selectedAccent = c),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _ReadyPage(
                    name: _nameController.text,
                    accentColor: accent.accent,
                    accentBg: accent.accentBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.xl3,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? "Let's go →" : 'Continue',
                    style: AppTextStyles.bodyL.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PAGE 1: Name ──────────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  const _NamePage({
    required this.controller,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });
  final TextEditingController controller;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('整える', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What should\nwe call you?',
            style: AppTextStyles.headingL.copyWith(color: textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl3),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: AppTextStyles.bodyL.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: AppTextStyles.bodyL.copyWith(color: textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Used in your greeting. Stored only on your device.',
            style: AppTextStyles.bodyS.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── PAGE 2: Accent Color ──────────────────────────────────────────────────────

class _AccentPage extends StatelessWidget {
  const _AccentPage({
    required this.selectedAccent,
    required this.onSelect,
    required this.textPrimary,
    required this.textSecondary,
  });
  final Color selectedAccent;
  final ValueChanged<Color> onSelect;
  final Color textPrimary;
  final Color textSecondary;

  static const _colorNames = {
    0xFF1D9E75: 'Teal',
    0xFF4A90D9: 'Blue',
    0xFF7F77DD: 'Purple',
    0xFFE24B4A: 'Red',
    0xFFEF9F27: 'Amber',
    0xFFD44C3A: 'Coral',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('テーマ', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick your\naccent color.',
            style: AppTextStyles.headingL.copyWith(color: textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl3),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: AppColors.accentPresets.map((color) {
              final isSelected = selectedAccent.value == color.value;
              final name = _colorNames[color.value] ?? '';
              return GestureDetector(
                onTap: () => onSelect(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: isSelected
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        name,
                        style: AppTextStyles.bodyM.copyWith(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── PAGE 3: Ready ─────────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.name,
    required this.accentColor,
    required this.accentBg,
    required this.textPrimary,
    required this.textSecondary,
  });
  final String name;
  final Color accentColor;
  final Color accentBg;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final greeting = name.isNotEmpty ? 'Ready, $name.' : 'All set.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('準備完了', style: AppTextStyles.jpSubtitle.copyWith(color: textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            greeting,
            style: AppTextStyles.headingL.copyWith(color: textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl3),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '整える is set up.',
                  style: AppTextStyles.bodyL.copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Everything is free, offline, and yours.',
                  style: AppTextStyles.bodyM.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FeaturePill(icon: Icons.lock_outline, label: '100% Offline', accentColor: accentColor),
          const SizedBox(height: AppSpacing.sm),
          _FeaturePill(icon: Icons.visibility_off_outlined, label: 'No tracking, no accounts', accentColor: accentColor),
          const SizedBox(height: AppSpacing.sm),
          _FeaturePill(icon: Icons.stars_outlined, label: 'All features free, forever', accentColor: accentColor),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });
  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodyM.copyWith(color: textPrimary)),
      ],
    );
  }
}
