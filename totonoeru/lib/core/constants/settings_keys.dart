/// All SharedPreferences keys used by Totonoeru.
/// Defaults are defined here and enforced in the SettingsProvider.
abstract final class SettingsKeys {
  // ── Profile ───────────────────────────────────────────────────────────────
  static const profileName = 'profile_name';
  static const profileAvatarEmoji = 'profile_avatar_emoji';

  // ── Appearance ────────────────────────────────────────────────────────────
  static const themeMode = 'theme_mode';       // 'system' | 'light' | 'dark'
  static const accentColorHex = 'accent_color_hex';
  static const fontSizeScale = 'font_size_scale';

  // ── Tasks ─────────────────────────────────────────────────────────────────
  static const defaultPriority = 'default_priority'; // 'medium' | 'high' | 'low'
  static const confirmBeforeDelete = 'confirm_before_delete';
  static const autoArchiveAfterDays = 'auto_archive_after_days';

  // ── Schedule ──────────────────────────────────────────────────────────────
  static const showFreeSlots = 'show_free_slots';
  static const nudgeUnscheduled = 'nudge_unscheduled';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notificationsEnabled = 'notifications_enabled';

  // ── Calendar ─────────────────────────────────────────────────────────────
  static const weekStartDay = 'week_start_day';        // 'sunday' | 'monday'
  static const defaultScheduleView = 'default_schedule_view'; // 'day' | 'week' | 'month'

  // ── Focus ─────────────────────────────────────────────────────────────────
  static const focusWorkMinutes = 'focus_work_minutes';
  static const focusBreakMinutes = 'focus_break_minutes';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const onboardingComplete = 'onboarding_complete';

  // ── Backup ────────────────────────────────────────────────────────────────
  static const lastBackupDate = 'last_backup_date';
}

/// Default values matching the spec exactly.
abstract final class SettingsDefaults {
  static const profileName = '';
  static const profileAvatarEmoji = '人';
  static const themeMode = 'system';
  static const accentColorHex = '#1D9E75';
  static const fontSizeScale = 1.0;
  static const defaultPriority = 'medium';
  static const confirmBeforeDelete = true;
  static const autoArchiveAfterDays = 7;
  static const showFreeSlots = true;
  static const nudgeUnscheduled = true;
  static const notificationsEnabled = true;
  static const weekStartDay = 'sunday';
  static const defaultScheduleView = 'day';
  static const focusWorkMinutes = 25;
  static const focusBreakMinutes = 5;
  static const onboardingComplete = false;
  static const lastBackupDate = '';
}
