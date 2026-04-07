import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.primary;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Accent preview (wired, works now) ─────────────────────────
          Text('Accent Color', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: AppColors.accentPresets.map((color) {
              final isSelected = color.value == accent.value;
              return GestureDetector(
                onTap: () => ref.read(accentColorProvider.notifier).setAccent(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)]
                        : [],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Full settings — Week 2',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: textPrimary.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}
