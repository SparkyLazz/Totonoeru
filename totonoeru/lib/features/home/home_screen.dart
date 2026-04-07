import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../shared/widgets/app_fab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

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
                    Text(
                      name.isNotEmpty ? '$greeting, $name.' : '$greeting.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        color: textPrimary.withOpacity(0.45),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Welcome card (task 1.37) ──────────────────────────
                    _WelcomeCard(accent: accent, textPrimary: textPrimary),
                    const SizedBox(height: 24),

                    // Placeholder sections — built in Week 4
                    _SectionPlaceholder(
                      label: 'Today\'s tasks',
                      accent: accent,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 20),
                    _SectionPlaceholder(
                      label: 'Upcoming blocks',
                      accent: accent,
                      textPrimary: textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddTask: () {}, // wired in Week 2
        onAddTimeBlock: () {}, // wired in Week 3
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

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.accent, required this.textPrimary});
  final Color accent;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '整える is set up',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything is free, offline, and yours.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {}, // opens Add Task sheet — wired in Week 2
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add your first task',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({
    required this.label,
    required this.accent,
    required this.textPrimary,
  });
  final String label;
  final Color accent;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Center(
            child: Text(
              'Built in Week 4',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                color: textPrimary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
