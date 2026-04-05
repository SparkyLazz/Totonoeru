import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP ACCENT COLORS — ThemeExtension
// Decision 4: ThemeExtension<AppAccentColors> + Riverpod provider rebuild.
// Never access accent color via AppColors directly in widgets —
// always use Theme.of(context).extension<AppAccentColors>()!
// ─────────────────────────────────────────────────────────────────────────────

class AppAccentColors extends ThemeExtension<AppAccentColors> {
  const AppAccentColors({
    required this.accent,
    required this.accentBg,
    required this.accentGlow,
  });

  /// Primary accent — buttons, active states, checkmarks
  final Color accent;

  /// Accent at ~10% opacity — chip backgrounds, subtle highlights
  final Color accentBg;

  /// Accent at ~25% opacity — glow effects, focus rings
  final Color accentGlow;

  /// Creates an AppAccentColors from a single accent Color.
  factory AppAccentColors.fromAccent(Color accent) {
    return AppAccentColors(
      accent: accent,
      accentBg: accent.withOpacity(0.10),
      accentGlow: accent.withOpacity(0.25),
    );
  }

  /// Default teal accent
  static final AppAccentColors defaults =
      AppAccentColors.fromAccent(AppColors.accentTeal);

  @override
  AppAccentColors copyWith({Color? accent, Color? accentBg, Color? accentGlow}) {
    return AppAccentColors(
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      accentGlow: accentGlow ?? this.accentGlow,
    );
  }

  @override
  AppAccentColors lerp(AppAccentColors? other, double t) {
    if (other == null) return this;
    return AppAccentColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
    );
  }
}
