import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS PROVIDER
// Persists: accent color, theme mode, onboarding complete flag.
// All other settings live here as the app grows.
// ─────────────────────────────────────────────────────────────────────────────

// SharedPreferences keys
const _kAccentColor       = 'accent_color';
const _kThemeMode         = 'theme_mode';
const _kOnboardingDone    = 'onboarding_complete';
const _kUserName          = 'user_name';
const _kWelcardDismissed  = 'welcome_card_dismissed';

// ── SHARED PREFERENCES INSTANCE ─────────────────────────────────────────────

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// ── SETTINGS NOTIFIER ────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.accentColor = AppColors.accentTeal,
    this.themeMode = ThemeMode.system,
    this.onboardingComplete = false,
    this.userName = '',
    this.welcomeCardDismissed = false,
  });

  final Color accentColor;
  final ThemeMode themeMode;
  final bool onboardingComplete;
  final String userName;
  final bool welcomeCardDismissed;

  SettingsState copyWith({
    Color? accentColor,
    ThemeMode? themeMode,
    bool? onboardingComplete,
    String? userName,
    bool? welcomeCardDismissed,
  }) {
    return SettingsState(
      accentColor: accentColor ?? this.accentColor,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      userName: userName ?? this.userName,
      welcomeCardDismissed: welcomeCardDismissed ?? this.welcomeCardDismissed,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.read(sharedPrefsProvider);
    return _loadFromPrefs();
  }

  SettingsState _loadFromPrefs() {
    // Accent color
    final colorValue = _prefs.getInt(_kAccentColor);
    final accent = colorValue != null
        ? Color(colorValue)
        : AppColors.accentTeal;

    // Theme mode
    final themeModeIndex = _prefs.getInt(_kThemeMode) ?? 0;
    final themeMode = ThemeMode.values[themeModeIndex.clamp(0, 2)];

    return SettingsState(
      accentColor: accent,
      themeMode: themeMode,
      onboardingComplete: _prefs.getBool(_kOnboardingDone) ?? false,
      userName: _prefs.getString(_kUserName) ?? '',
      welcomeCardDismissed: _prefs.getBool(_kWelcardDismissed) ?? false,
    );
  }

  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(_kAccentColor, color.value);
    state = state.copyWith(accentColor: color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_kThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> completeOnboarding(String name) async {
    await _prefs.setBool(_kOnboardingDone, true);
    await _prefs.setString(_kUserName, name);
    state = state.copyWith(onboardingComplete: true, userName: name);
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_kUserName, name);
    state = state.copyWith(userName: name);
  }

  Future<void> dismissWelcomeCard() async {
    await _prefs.setBool(_kWelcardDismissed, true);
    state = state.copyWith(welcomeCardDismissed: true);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ── CONVENIENCE PROVIDERS ────────────────────────────────────────────────────

final accentColorProvider = Provider<Color>(
  (ref) => ref.watch(settingsProvider).accentColor,
);

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider).themeMode,
);

final onboardingCompleteProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).onboardingComplete,
);
