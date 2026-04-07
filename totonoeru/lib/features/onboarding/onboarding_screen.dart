import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentStep = 0;
  Color _selectedAccent = AppColors.accentTeal;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) return;
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(profileNameProvider.notifier).setName(name);
    }
    await ref.read(accentColorProvider.notifier).setAccent(_selectedAccent);
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Step indicator ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i <= _currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: active
                            ? _selectedAccent
                            : _selectedAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepName(
                    controller: _nameController,
                    accent: _selectedAccent,
                    textPrimary: textPrimary,
                    onNext: _nextStep,
                  ),
                  _StepAccent(
                    selected: _selectedAccent,
                    onSelect: (c) => setState(() => _selectedAccent = c),
                    textPrimary: textPrimary,
                    onNext: _nextStep,
                  ),
                  _StepLetsGo(
                    accent: _selectedAccent,
                    textPrimary: textPrimary,
                    onFinish: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1 — Name ─────────────────────────────────────────────────────────────

class _StepName extends StatelessWidget {
  const _StepName({
    required this.controller,
    required this.accent,
    required this.textPrimary,
    required this.onNext,
  });

  final TextEditingController controller;
  final Color accent;
  final Color textPrimary;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text(
            '整える',
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: accent,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'What should we call you?',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Your name stays on your device. Nothing leaves.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: textPrimary.withOpacity(0.5),
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Your name',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
            onSubmitted: (_) => onNext(),
          ).animate().fadeIn(delay: 400.ms),
          const Spacer(),
          _NextButton(accent: accent, label: 'Continue', onTap: onNext),
        ],
      ),
    );
  }
}

// ── Step 2 — Accent Color ─────────────────────────────────────────────────────

class _StepAccent extends StatelessWidget {
  const _StepAccent({
    required this.selected,
    required this.onSelect,
    required this.textPrimary,
    required this.onNext,
  });

  final Color selected;
  final ValueChanged<Color> onSelect;
  final Color textPrimary;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text(
            'Pick your color',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'This accent color will be yours across the whole app.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: textPrimary.withOpacity(0.5),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: AppColors.accentPresets.map((color) {
              final isSelected = color.value == selected.value;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelect(color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 300.ms),
          const Spacer(),
          _NextButton(accent: selected, label: 'Continue', onTap: onNext),
        ],
      ),
    );
  }
}

// ── Step 3 — Let's Go ─────────────────────────────────────────────────────────

class _StepLetsGo extends StatelessWidget {
  const _StepLetsGo({
    required this.accent,
    required this.textPrimary,
    required this.onFinish,
  });

  final Color accent;
  final Color textPrimary;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text(
            'You\'re all set.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'Everything is free.\nEverything is offline.\nEverything is yours.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w300,
              height: 1.6,
              color: textPrimary.withOpacity(0.7),
            ),
          ).animate().fadeIn(delay: 250.ms),
          const Spacer(),
          _NextButton(
            accent: accent,
            label: "Let's go →",
            onTap: onFinish,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'No account. No ads. No tracking. Ever.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                color: textPrimary.withOpacity(0.35),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

// ── Shared Next Button ────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.accent,
    required this.label,
    required this.onTap,
  });

  final Color accent;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
