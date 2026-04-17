// lib/features/focus/focus_sessions_screen.dart
// Task 5.13 — Full session history list (route: /focus/sessions)
//
// FIX (line 125): Container decoration — borderRadius takes BorderRadius,
// not a plain double. Use BorderRadius.circular(12) explicitly.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/focus_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/focus_session.dart';
import '../../data/repositories/focus_repository.dart';

// plain double constants — no AppRadius dependency
const double _kCardRadius = 12.0;
const double _kIconRadius = 8.0;

// Provider for all sessions (not just today)
final allSessionsProvider = FutureProvider<List<FocusSession>>((ref) {
  return FocusRepository.instance.getAllSessions();
});

class FocusSessionsScreen extends ConsumerWidget {
  const FocusSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'セッション履歴',
              style: TextStyle(
                fontSize: 11,
                color: cs.onBackground.withOpacity(0.3),
                fontFamily: 'NotoSansJP',
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        leading: const BackButton(),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                'No sessions recorded yet',
                style: TextStyle(
                    color: cs.onBackground.withOpacity(0.35)),
              ),
            );
          }

          // Group by date string
          final grouped = <String, List<FocusSession>>{};
          for (final s in sessions) {
            final key = DateFormat('MMMM d, yyyy')
                .format(s.startedAt ?? DateTime.now());
            grouped.putIfAbsent(key, () => []).add(s);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: cs.onBackground.withOpacity(0.35),
                      ),
                    ),
                  ),
                  ...entry.value.map((s) => _SessionCard(session: s)),
                ],
              );
            }).toList(),
          );
        },
        loading: () =>
        const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) =>
        const Center(child: Text('Error loading sessions')),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mins = session.durationSeconds ~/ 60;
    final secs = session.durationSeconds % 60;
    final dur =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    String timeStr = '';
    if (session.startedAt != null) {
      final t = TimeOfDay.fromDateTime(session.startedAt!);
      timeStr =
      '${t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period.name.toUpperCase()}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        // FIX: BorderRadius.circular(double) — correct usage
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: session.completed
                  ? AppColors.accentTeal.withOpacity(0.12)
                  : AppColors.priorityMedium.withOpacity(0.12),
              // FIX: same — BorderRadius.circular(double)
              borderRadius: BorderRadius.circular(_kIconRadius),
            ),
            child: Icon(
              session.completed
                  ? Icons.check_circle_outline_rounded
                  : Icons.coffee_rounded,
              size: 15,
              color: session.completed
                  ? AppColors.accentTeal
                  : AppColors.priorityMedium,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.completed ? 'Work session' : 'Short break',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${session.completed ? 'Completed' : 'Break'} · $timeStr',
                  style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          Text(
            dur,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'DMMono',
              color: cs.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}