import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/settings_keys.dart';
import '../theme/app_colors.dart';

// ── Raw SharedPreferences Provider ────────────────────────────────────────────
// Overridden in main() after async init.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  );
});

// ── Accent Color Provider (task 1.10, 1.11, 1.12) ────────────────────────────
/// Holds the currently selected accent Color.
/// Persisted as hex to SharedPreferences on every change.
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccentColorNotifier(prefs);
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier(this._prefs)
      : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Color _load(SharedPreferences prefs) {
    final hex = prefs.getString(SettingsKeys.accentColorHex) ??
        SettingsDefaults.accentColorHex;
    return AppColors.accentFromHex(hex);
  }

  /// Update accent and persist to SharedPreferences.
  Future<void> setAccent(Color color) async {
    state = color;
    await _prefs.setString(
      SettingsKeys.accentColorHex,
      AppColors.hexFromColor(color),
    );
  }
}

// ── Theme Mode Provider ───────────────────────────────────────────────────────
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final val = prefs.getString(SettingsKeys.themeMode) ??
        SettingsDefaults.themeMode;
    return switch (val) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final val = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(SettingsKeys.themeMode, val);
  }
}

// ── Onboarding Complete Provider ──────────────────────────────────────────────
final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._prefs)
      : super(
          _prefs.getBool(SettingsKeys.onboardingComplete) ??
              SettingsDefaults.onboardingComplete,
        );

  final SharedPreferences _prefs;

  Future<void> complete() async {
    state = true;
    await _prefs.setBool(SettingsKeys.onboardingComplete, true);
  }
}

// ── Profile Name Provider ─────────────────────────────────────────────────────
final profileNameProvider =
    StateNotifierProvider<ProfileNameNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileNameNotifier(prefs);
});

class ProfileNameNotifier extends StateNotifier<String> {
  ProfileNameNotifier(this._prefs)
      : super(
          _prefs.getString(SettingsKeys.profileName) ??
              SettingsDefaults.profileName,
        );

  final SharedPreferences _prefs;

  Future<void> setName(String name) async {
    state = name;
    await _prefs.setString(SettingsKeys.profileName, name);
  }
}
