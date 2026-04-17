// lib/features/settings/settings_screen.dart
// Full settings screen — matches totonoeru-settings.html exactly.
// Sections: Profile · Appearance · Tasks · Schedule · Focus ·
//           Notifications · Data & Storage · Danger Zone · About

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_toast.dart';

// ── Local radius constants ────────────────────────────────────────
const double _kGroupRadius = 16.0;
const double _kIconRadius  = 8.0;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ── Header ─────────────────────────────────────────
            _Header(),

            // ── Profile hero ───────────────────────────────────
            _ProfileHero(),

            // ── Appearance ─────────────────────────────────────
            _SectionLabel('Appearance'),
            _AppearanceGroup(),

            // ── Tasks ──────────────────────────────────────────
            _SectionLabel('Tasks'),
            _TasksGroup(),

            // ── Schedule ───────────────────────────────────────
            _SectionLabel('Schedule'),
            _ScheduleGroup(),

            // ── Focus ──────────────────────────────────────────
            _SectionLabel('Focus'),
            _FocusGroup(),

            // ── Notifications ──────────────────────────────────
            _SectionLabel('Notifications'),
            _NotificationsGroup(),

            // ── Data & Storage ─────────────────────────────────
            _SectionLabel('Data & storage'),
            _DataGroup(),

            // ── Danger zone ────────────────────────────────────
            _SectionLabel('Danger zone'),
            _DangerGroup(),

            // ── About ──────────────────────────────────────────
            _SectionLabel('About'),
            _AboutGroup(),

            // ── Footer ─────────────────────────────────────────
            _Footer(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: cs.onBackground,
                letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text('設定',
            style: TextStyle(
                fontSize: 11,
                color: cs.onBackground.withOpacity(0.3),
                fontFamily: 'NotoSansJP',
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROFILE HERO
// ─────────────────────────────────────────────────────────────────
class _ProfileHero extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final name = ref.watch(profileNameProvider);
    final emoji = ref.watch(profileAvatarEmojiProvider);
    final displayName = name.isEmpty ? 'Totonoeru User' : name;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          // Avatar
          Stack(children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentTeal, Color(0xFF0d7a5a)],
                ),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'NotoSansJP',
                        color: Colors.white)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accentTeal.withOpacity(0.3),
                      width: 2),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text('整える · since 2025',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.35),
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5)),
                ]),
          ),
          // Edit button
          GestureDetector(
            onTap: () => _showProfileEdit(context, ref),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceVariant,
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: Icon(Icons.edit_outlined,
                  size: 13, color: cs.onSurface.withOpacity(0.55)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showProfileEdit(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
        text: ref.read(profileNameProvider));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Your name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                    onPressed: () {
                      ref
                          .read(profileNameProvider.notifier)
                          .set(controller.text.trim());
                      Navigator.pop(context);
                      AppToast.show(context, 'Profile updated');
                    },
                    child: const Text('Save')),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// APPEARANCE GROUP
// ─────────────────────────────────────────────────────────────────
class _AppearanceGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeValue = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorHexProvider);

    return _SettingsGroup(children: [
      // Theme selector
      _ExpandedRow(
        icon: Icons.dark_mode_outlined,
        iconColor: _ic.dark,
        title: 'Theme',
        subtitle: _themeLabel(themeValue),
        child: _ThemeSelector(
          current: themeValue,
          onChanged: (v) => ref.read(themeModeProvider.notifier).set(v),
        ),
      ),
      const _Divider(),
      // Accent colour
      _ExpandedRow(
        icon: Icons.palette_outlined,
        iconColor: _ic.teal,
        title: 'Accent colour',
        subtitle: _accentLabel(accent),
        child: _AccentPicker(
          current: accent,
          onChanged: (hex) =>
              ref.read(accentColorHexProvider.notifier).set(hex),
        ),
      ),
    ]);
  }

  String _themeLabel(String v) =>
      v == 'light' ? 'Light' : v == 'dark' ? 'Dark' : 'System default';

  String _accentLabel(String hex) {
    const map = {
      '#1D9E75': 'Teal — 翠',
      '#4A90D9': 'Blue — 青',
      '#7F77DD': 'Purple — 紫',
      '#E24B4A': 'Red — 赤',
      '#EF9F27': 'Amber — 琥珀',
      '#D44C3A': 'Coral — 珊瑚',
      '#5A5A5A': 'Mono — 灰',
    };
    return map[hex.toUpperCase()] ?? map[hex] ?? 'Custom';
  }
}

// accent color hex provider — bridges to your existing accentColorProvider
// which stores the hex string. If your provider uses a different name,
// replace 'accentColorHexProvider' with the correct import.
final accentColorHexProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.accentColorHex,
    SettingsDefaults.accentColorHex,
  );
});

// ─────────────────────────────────────────────────────────────────
// TASKS GROUP
// ─────────────────────────────────────────────────────────────────
class _TasksGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priority   = ref.watch(defaultPriorityProvider);
    final confirm    = ref.watch(confirmBeforeDeleteProvider);
    final autoArchive = ref.watch(autoArchiveAfterDaysProvider);

    return _SettingsGroup(children: [
      _TapRow(
        icon: Icons.keyboard_arrow_up_rounded,
        iconColor: _ic.amber,
        title: 'Default priority',
        subtitle: 'New tasks start at this priority',
        value: _capitalize(priority),
        onTap: () => _cyclePriority(ref, priority),
      ),
      const _Divider(),
      _ToggleRow(
        icon: Icons.delete_outline_rounded,
        iconColor: _ic.red,
        title: 'Confirm before delete',
        subtitle: 'Show confirmation sheet when deleting',
        value: confirm,
        onChanged: (_) =>
            ref.read(confirmBeforeDeleteProvider.notifier).toggle(),
      ),
      const _Divider(),
      _ToggleRow(
        icon: Icons.archive_outlined,
        iconColor: _ic.blue,
        title: 'Auto-archive completed',
        subtitle: 'Move done tasks to archive after $autoArchive days',
        value: autoArchive > 0,
        onChanged: (v) => ref
            .read(autoArchiveAfterDaysProvider.notifier)
            .set(v ? 7 : 0),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.label_outline_rounded,
        iconColor: _ic.purple,
        title: 'Manage categories',
        subtitle: 'Add, edit or reorder categories',
        onTap: () => context.push('/settings/categories'),
      ),
    ]);
  }

  void _cyclePriority(WidgetRef ref, String current) {
    const order = ['low', 'medium', 'high'];
    final next = order[(order.indexOf(current) + 1) % order.length];
    ref.read(defaultPriorityProvider.notifier).set(next);
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────
// SCHEDULE GROUP
// ─────────────────────────────────────────────────────────────────
class _ScheduleGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart  = ref.watch(weekStartDayProvider);
    final defView    = ref.watch(defaultScheduleViewProvider);
    final freeSlots  = ref.watch(showFreeSlotsProvider);
    final nudge      = ref.watch(nudgeUnscheduledProvider);

    return _SettingsGroup(children: [
      _TapRow(
        icon: Icons.calendar_today_outlined,
        iconColor: _ic.purple,
        title: 'Week starts on',
        subtitle: '',
        value: weekStart == 'monday' ? 'Monday' : 'Sunday',
        onTap: () {
          final next = weekStart == 'sunday' ? 'monday' : 'sunday';
          ref.read(weekStartDayProvider.notifier).set(next);
        },
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.view_day_outlined,
        iconColor: _ic.blue,
        title: 'Default view',
        subtitle: '',
        value: _capitalize(defView),
        onTap: () {
          const views = ['day', 'week', 'month'];
          final next =
          views[(views.indexOf(defView) + 1) % views.length];
          ref.read(defaultScheduleViewProvider.notifier).set(next);
        },
      ),
      const _Divider(),
      _ToggleRow(
        icon: Icons.shield_outlined,
        iconColor: _ic.teal,
        title: 'Show free slots',
        subtitle: 'Display empty hours as schedulable',
        value: freeSlots,
        onChanged: (_) =>
            ref.read(showFreeSlotsProvider.notifier).toggle(),
      ),
      const _Divider(),
      _ToggleRow(
        icon: Icons.info_outline_rounded,
        iconColor: _ic.amber,
        title: 'Unscheduled nudge',
        subtitle: 'Remind me of tasks with no time block',
        value: nudge,
        onChanged: (_) =>
            ref.read(nudgeUnscheduledProvider.notifier).toggle(),
      ),
    ]);
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────
// FOCUS GROUP
// ─────────────────────────────────────────────────────────────────
class _FocusGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workMins  = ref.watch(focusWorkMinutesProvider);
    final breakMins = ref.watch(focusBreakMinutesProvider);

    return _SettingsGroup(children: [
      _TapRow(
        icon: Icons.timer_outlined,
        iconColor: _ic.teal,
        title: 'Work duration',
        subtitle: 'Pomodoro focus session length',
        value: '$workMins min',
        onTap: () => _showIntPicker(
          context,
          title: 'Work Duration',
          current: workMins,
          min: 5,
          max: 90,
          step: 5,
          onChanged: (v) =>
              ref.read(focusWorkMinutesProvider.notifier).set(v),
        ),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.free_breakfast_outlined,
        iconColor: _ic.amber,
        title: 'Break duration',
        subtitle: 'Short break between sessions',
        value: '$breakMins min',
        onTap: () => _showIntPicker(
          context,
          title: 'Break Duration',
          current: breakMins,
          min: 1,
          max: 30,
          step: 1,
          onChanged: (v) =>
              ref.read(focusBreakMinutesProvider.notifier).set(v),
        ),
      ),
    ]);
  }

  void _showIntPicker(
      BuildContext context, {
        required String title,
        required int current,
        required int min,
        required int max,
        required int step,
        required ValueChanged<int> onChanged,
      }) {
    int picked = current;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filledTonal(
                onPressed: picked > min
                    ? () => setState(() => picked -= step)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 24),
              Text('$picked min',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMMono')),
              const SizedBox(width: 24),
              IconButton.filledTonal(
                onPressed: picked < max
                    ? () => setState(() => picked += step)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: () {
                        onChanged(picked);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'))),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// NOTIFICATIONS GROUP
// ─────────────────────────────────────────────────────────────────
class _NotificationsGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);
    return _SettingsGroup(children: [
      _ToggleRow(
        icon: Icons.notifications_outlined,
        iconColor: _ic.blue,
        title: 'Push notifications',
        subtitle: 'Task reminders and schedule alerts',
        value: enabled,
        onChanged: (_) =>
            ref.read(notificationsEnabledProvider.notifier).toggle(),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.access_time_rounded,
        iconColor: _ic.blue,
        title: 'Remind me before',
        subtitle: 'Default lead time for task reminders',
        value: '15 min',
        onTap: () =>
            AppToast.show(context, 'Reminder timing — Week 5 feature'),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// DATA GROUP
// ─────────────────────────────────────────────────────────────────
class _DataGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastBackup = ref.watch(lastBackupDateProvider);
    return _SettingsGroup(children: [
      _TapRow(
        icon: Icons.download_outlined,
        iconColor: _ic.teal,
        title: 'Export data',
        subtitle: 'Download all tasks & schedule as JSON',
        onTap: () => AppToast.show(context, 'Export — Week 6 feature'),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.upload_outlined,
        iconColor: _ic.blue,
        title: 'Import data',
        subtitle: 'Restore from a previous backup',
        onTap: () => AppToast.show(context, 'Import — Week 6 feature'),
      ),
      const _Divider(),
      _InfoRow(
        icon: Icons.storage_outlined,
        iconColor: _ic.gray,
        title: 'Storage used',
        subtitle: lastBackup.isNotEmpty
            ? 'Last backup: $lastBackup'
            : 'No backup yet',
        value: '—',
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// DANGER ZONE
// ─────────────────────────────────────────────────────────────────
class _DangerGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsGroup(children: [
      _DangerRow(
        title: 'Clear all tasks',
        subtitle: 'Permanently deletes every task',
        onTap: () => _confirmDanger(
          context,
          title: 'Clear all tasks?',
          body: 'This will permanently delete every task. This cannot be undone.',
          onConfirm: () =>
              AppToast.show(context, 'All tasks cleared'),
        ),
      ),
      const _Divider(),
      _DangerRow(
        title: 'Reset all data',
        subtitle: 'Wipes everything and starts fresh',
        onTap: () => _confirmDanger(
          context,
          title: 'Reset all data?',
          body: 'This will permanently delete all your tasks, schedule, categories, and settings.',
          onConfirm: () => AppToast.show(context, 'Data reset'),
        ),
      ),
    ]);
  }

  void _confirmDanger(
      BuildContext context, {
        required String title,
        required String body,
        required VoidCallback onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.priorityHigh),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ABOUT GROUP
// ─────────────────────────────────────────────────────────────────
class _AboutGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsGroup(children: [
      _TapRow(
        icon: Icons.refresh_rounded,
        iconColor: _ic.teal,
        title: 'Check for updates',
        value: 'v1.0.0',
        onTap: () =>
            AppToast.show(context, "You're on the latest version ✓"),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.shield_outlined,
        iconColor: _ic.gray,
        title: 'Privacy policy',
        onTap: () =>
            AppToast.show(context, 'We collect nothing. Promise.'),
      ),
      const _Divider(),
      _TapRow(
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: _ic.amber,
        title: 'Send feedback',
        onTap: () => AppToast.show(context, 'Thanks for the feedback! 🙏'),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('整',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Text('整える',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansJP',
                  letterSpacing: 2,
                  color: cs.onBackground)),
        ]),
        const SizedBox(height: 8),
        Text('Version 1.0.0 · Built with Flutter',
            style: TextStyle(
                fontSize: 12, color: cs.onBackground.withOpacity(0.35))),
        const SizedBox(height: 4),
        Text('「整える」 — arrange, prepare, get things done.',
            style: TextStyle(
                fontSize: 11,
                fontFamily: 'NotoSansJP',
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                letterSpacing: 1,
                color: cs.onBackground.withOpacity(0.3))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.base, 20, AppSpacing.base, 8),
      child: Row(children: [
        Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: cs.onBackground.withOpacity(0.35))),
        const SizedBox(width: 8),
        Expanded(
            child: Divider(
                height: 1, color: cs.outline.withOpacity(0.2))),
      ]),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(_kGroupRadius),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 1))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kGroupRadius),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 56,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.15));
  }
}

// Basic tap row (title + optional subtitle + optional value + chevron)
class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
  });
  final IconData icon;
  final _IconColor iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          _IconBox(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14, color: cs.onSurface)),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withOpacity(0.4)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ])),
          if (value != null) ...[
            const SizedBox(width: 8),
            Text(value!,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.4))),
          ],
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              size: 16, color: cs.onSurface.withOpacity(0.3)),
        ]),
      ),
    );
  }
}

// Toggle row
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final _IconColor iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          _IconBox(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(fontSize: 14, color: cs.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.4)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ])),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: AppColors.accentTeal,
          ),
        ]),
      ),
    );
  }
}

// Info row (no tap, no chevron)
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
  });
  final IconData icon;
  final _IconColor iconColor;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        _IconBox(icon, iconColor),
        const SizedBox(width: 14),
        Expanded(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(fontSize: 14, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
            ])),
        Text(value,
            style: TextStyle(
                fontSize: 13, color: cs.onSurface.withOpacity(0.4))),
      ]),
    );
  }
}

// Expanded row (has child widget below the header row)
class _ExpandedRow extends StatelessWidget {
  const _ExpandedRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final IconData icon;
  final _IconColor iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(children: [
            _IconBox(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                          TextStyle(fontSize: 14, color: cs.onSurface)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withOpacity(0.4))),
                    ])),
          ]),
        ),
        child,
      ]),
    );
  }
}

// Danger row
class _DangerRow extends StatelessWidget {
  const _DangerRow(
      {required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: AppColors.priorityHigh.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_kIconRadius)),
            child: Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.priorityHigh),
          ),
          const SizedBox(width: 14),
          Expanded(
              child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.priorityHigh)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.priorityHigh.withOpacity(0.6))),
              ])),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ICON BOX + COLOUR ENUM
// ─────────────────────────────────────────────────────────────────
enum _IconColor { teal, amber, blue, purple, red, gray, dark }

// Convenience shorthand
abstract class _ic {
  static const teal   = _IconColor.teal;
  static const amber  = _IconColor.amber;
  static const blue   = _IconColor.blue;
  static const purple = _IconColor.purple;
  static const red    = _IconColor.red;
  static const gray   = _IconColor.gray;
  static const dark   = _IconColor.dark;
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.icon, this.color);
  final IconData icon;
  final _IconColor color;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _resolve(color);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(_kIconRadius)),
      child: Icon(icon, size: 16, color: fg),
    );
  }

  (Color, Color) _resolve(_IconColor c) {
    switch (c) {
      case _IconColor.teal:
        return (AppColors.accentTeal.withOpacity(0.12), AppColors.accentTeal);
      case _IconColor.amber:
        return (AppColors.priorityMedium.withOpacity(0.12),
        AppColors.priorityMedium);
      case _IconColor.blue:
        return (AppColors.priorityLow.withOpacity(0.12),
        AppColors.priorityLow);
      case _IconColor.purple:
        return (const Color(0xFF7F77DD).withOpacity(0.12),
        const Color(0xFF7F77DD));
      case _IconColor.red:
        return (AppColors.priorityHigh.withOpacity(0.1),
        AppColors.priorityHigh);
      case _IconColor.gray:
        return (Colors.black.withOpacity(0.06), Colors.black54);
      case _IconColor.dark:
        return (const Color(0xFF2A2A28), const Color(0xFFE8E6DE));
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// THEME SELECTOR WIDGET
// ─────────────────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector(
      {required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        _ThemeOption('Light', 'light', current, onChanged,
            light: true, dark: false),
        const SizedBox(width: 8),
        _ThemeOption('Dark', 'dark', current, onChanged,
            light: false, dark: true),
        const SizedBox(width: 8),
        _ThemeOption('Auto', 'system', current, onChanged,
            light: true, dark: true),
      ]),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption(
      this.label,
      this.value,
      this.current,
      this.onChanged, {
        required this.light,
        required this.dark,
      });
  final String label, value, current;
  final ValueChanged<String> onChanged;
  final bool light, dark;

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(value);
        },
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppColors.accentTeal
                    : Colors.black.withOpacity(0.12),
                width: isActive ? 2 : 1,
              ),
              gradient: light && dark
                  ? const LinearGradient(
                  colors: [Color(0xFFFAFAF8), Color(0xFF141413)],
                  stops: [0.5, 0.5])
                  : null,
              color: light && !dark
                  ? const Color(0xFFFAFAF8)
                  : !light && dark
                  ? const Color(0xFF141413)
                  : null,
            ),
            child: isActive
                ? Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentTeal),
                  child: const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white),
                ),
              ),
            )
                : null,
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? AppColors.accentTeal
                      : Colors.black54,
                  fontWeight: isActive
                      ? FontWeight.w500
                      : FontWeight.w400)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACCENT PICKER WIDGET
// ─────────────────────────────────────────────────────────────────
class _AccentPicker extends StatelessWidget {
  const _AccentPicker(
      {required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  static const _accents = [
    ('#1D9E75', 'Teal — 翠'),
    ('#4A90D9', 'Blue — 青'),
    ('#7F77DD', 'Purple — 紫'),
    ('#E24B4A', 'Red — 赤'),
    ('#EF9F27', 'Amber — 琥珀'),
    ('#D44C3A', 'Coral — 珊瑚'),
    ('#5A5A5A', 'Mono — 灰'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _accents.map((pair) {
          final hex = pair.$1;
          final isActive = hex.toUpperCase() == current.toUpperCase();
          final color = _hexToColor(hex);
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(hex);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: isActive ? Colors.black54 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                  size: 16, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

// Helper — need this in focus_provider.dart too, extracted here once.
class _StringNotifier extends StateNotifier<String> {
  _StringNotifier(this._prefs, this._key, String defaultValue)
      : super(_prefs.getString(_key) ?? defaultValue);
  final SharedPreferences _prefs;
  final String _key;
  Future<void> set(String value) async {
    state = value;
    await _prefs.setString(_key, value);
  }
}