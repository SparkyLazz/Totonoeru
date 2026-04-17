// lib/core/providers/settings_provider.dart
// All 17 SharedPreferences keys + Riverpod providers
// Covers: profile, appearance, tasks, schedule, focus, notifications, data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────
// RAW SharedPreferences provider
// Overridden in ProviderScope at app startup with the already-loaded
// instance so every provider below is synchronous after first read.
// ─────────────────────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider in ProviderScope before use.',
  );
});

// ─────────────────────────────────────────────────────────────────
// KEY CONSTANTS  (single source of truth — reference from any file)
// ─────────────────────────────────────────────────────────────────
abstract class SettingsKeys {
  static const profileName           = 'profile_name';
  static const profileAvatarEmoji    = 'profile_avatar_emoji';
  static const themeMode             = 'theme_mode';          // 'light'|'dark'|'system'
  static const accentColorHex        = 'accent_color_hex';
  static const fontSizeScale         = 'font_size_scale';
  static const defaultPriority       = 'default_priority';    // 'high'|'medium'|'low'
  static const confirmBeforeDelete   = 'confirm_before_delete';
  static const autoArchiveAfterDays  = 'auto_archive_after_days';
  static const showFreeSlots         = 'show_free_slots';
  static const nudgeUnscheduled      = 'nudge_unscheduled';
  static const notificationsEnabled  = 'notifications_enabled';
  static const weekStartDay          = 'week_start_day';       // 'sunday'|'monday'
  static const defaultScheduleView   = 'default_schedule_view';// 'day'|'week'|'month'
  static const focusWorkMinutes      = 'focus_work_minutes';
  static const focusBreakMinutes     = 'focus_break_minutes';
  static const onboardingComplete    = 'onboarding_complete';
  static const lastBackupDate        = 'last_backup_date';
}

// ─────────────────────────────────────────────────────────────────
// DEFAULTS
// ─────────────────────────────────────────────────────────────────
abstract class SettingsDefaults {
  static const profileName           = '';
  static const profileAvatarEmoji    = '人';
  static const themeMode             = 'system';
  static const accentColorHex        = '#1D9E75';
  static const fontSizeScale         = 1.0;
  static const defaultPriority       = 'medium';
  static const confirmBeforeDelete   = true;
  static const autoArchiveAfterDays  = 7;
  static const showFreeSlots         = true;
  static const nudgeUnscheduled      = true;
  static const notificationsEnabled  = true;
  static const weekStartDay          = 'sunday';
  static const defaultScheduleView   = 'day';
  static const focusWorkMinutes      = 25;
  static const focusBreakMinutes     = 5;
  static const onboardingComplete    = false;
  static const lastBackupDate        = '';
}

// ─────────────────────────────────────────────────────────────────
// GENERIC NOTIFIERS
// ─────────────────────────────────────────────────────────────────

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

class _BoolNotifier extends StateNotifier<bool> {
  _BoolNotifier(this._prefs, this._key, bool defaultValue)
      : super(_prefs.getBool(_key) ?? defaultValue);
  final SharedPreferences _prefs;
  final String _key;
  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
  void toggle() => set(!state);
}

class _IntNotifier extends StateNotifier<int> {
  _IntNotifier(this._prefs, this._key, int defaultValue)
      : super(_prefs.getInt(_key) ?? defaultValue);
  final SharedPreferences _prefs;
  final String _key;
  Future<void> set(int value) async {
    state = value;
    await _prefs.setInt(_key, value);
  }
}

class _DoubleNotifier extends StateNotifier<double> {
  _DoubleNotifier(this._prefs, this._key, double defaultValue)
      : super(_prefs.getDouble(_key) ?? defaultValue);
  final SharedPreferences _prefs;
  final String _key;
  Future<void> set(double value) async {
    state = value;
    await _prefs.setDouble(_key, value);
  }
}

// ─────────────────────────────────────────────────────────────────
// INDIVIDUAL PROVIDERS  (one per key)
// ─────────────────────────────────────────────────────────────────

// ── Profile ──────────────────────────────────────────────────────
final profileNameProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.profileName,
    SettingsDefaults.profileName,
  );
});

final profileAvatarEmojiProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.profileAvatarEmoji,
    SettingsDefaults.profileAvatarEmoji,
  );
});

// ── Appearance ───────────────────────────────────────────────────
final themeModeProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.themeMode,
    SettingsDefaults.themeMode,
  );
});

/// Convenience: resolves the stored string to Flutter's ThemeMode enum.
final resolvedThemeModeProvider = Provider<ThemeMode>((ref) {
  final value = ref.watch(themeModeProvider);
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

// accent_color_hex is managed by the existing accentColorProvider
// (which reads/writes 'accent_color_hex' to SharedPreferences).
// We expose it here as an alias so SettingsScreen can import one file.
// DO NOT create a second provider — reference the one in app_theme / core.

final fontSizeScaleProvider =
StateNotifierProvider<_DoubleNotifier, double>((ref) {
  return _DoubleNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.fontSizeScale,
    SettingsDefaults.fontSizeScale,
  );
});

// ── Tasks ─────────────────────────────────────────────────────────
final defaultPriorityProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.defaultPriority,
    SettingsDefaults.defaultPriority,
  );
});

final confirmBeforeDeleteProvider =
StateNotifierProvider<_BoolNotifier, bool>((ref) {
  return _BoolNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.confirmBeforeDelete,
    SettingsDefaults.confirmBeforeDelete,
  );
});

final autoArchiveAfterDaysProvider =
StateNotifierProvider<_IntNotifier, int>((ref) {
  return _IntNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.autoArchiveAfterDays,
    SettingsDefaults.autoArchiveAfterDays,
  );
});

// ── Schedule ─────────────────────────────────────────────────────
final showFreeSlotsProvider =
StateNotifierProvider<_BoolNotifier, bool>((ref) {
  return _BoolNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.showFreeSlots,
    SettingsDefaults.showFreeSlots,
  );
});

final nudgeUnscheduledProvider =
StateNotifierProvider<_BoolNotifier, bool>((ref) {
  return _BoolNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.nudgeUnscheduled,
    SettingsDefaults.nudgeUnscheduled,
  );
});

final weekStartDayProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.weekStartDay,
    SettingsDefaults.weekStartDay,
  );
});

final defaultScheduleViewProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.defaultScheduleView,
    SettingsDefaults.defaultScheduleView,
  );
});

// ── Focus ─────────────────────────────────────────────────────────
final focusWorkMinutesProvider =
StateNotifierProvider<_IntNotifier, int>((ref) {
  return _IntNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.focusWorkMinutes,
    SettingsDefaults.focusWorkMinutes,
  );
});

final focusBreakMinutesProvider =
StateNotifierProvider<_IntNotifier, int>((ref) {
  return _IntNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.focusBreakMinutes,
    SettingsDefaults.focusBreakMinutes,
  );
});

// ── Notifications ─────────────────────────────────────────────────
final notificationsEnabledProvider =
StateNotifierProvider<_BoolNotifier, bool>((ref) {
  return _BoolNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.notificationsEnabled,
    SettingsDefaults.notificationsEnabled,
  );
});

// ── Meta ──────────────────────────────────────────────────────────
final onboardingCompleteProvider =
StateNotifierProvider<_BoolNotifier, bool>((ref) {
  return _BoolNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.onboardingComplete,
    SettingsDefaults.onboardingComplete,
  );
});

final lastBackupDateProvider =
StateNotifierProvider<_StringNotifier, String>((ref) {
  return _StringNotifier(
    ref.watch(sharedPreferencesProvider),
    SettingsKeys.lastBackupDate,
    SettingsDefaults.lastBackupDate,
  );
});

// ─────────────────────────────────────────────────────────────────
// MAIN.DART WIRING (add this to your ProviderScope override list)
// ─────────────────────────────────────────────────────────────────
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
//   runApp(
//     ProviderScope(
//       overrides: [
//         sharedPreferencesProvider.overrideWithValue(prefs),
//       ],
//       child: const TotonoeuApp(),
//     ),
//   );
// }