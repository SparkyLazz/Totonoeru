import 'package:flutter/material.dart';

/// ThemeExtension that carries the current accent color and its derived tints.
///
/// Fields:
///   accent      — the raw accent color (e.g. Color(0xFF1D9E75))
///   accentBg    — accent at 10% opacity — used for chip/card backgrounds
///   accentGlow  — accent at 25% opacity — used for focus rings, glows
///   accentText  — guaranteed legible on dark backgrounds (same as accent
///                 unless the accent is too dark, in which case lightened)
class AppAccentColors extends ThemeExtension<AppAccentColors> {
  const AppAccentColors({
    required this.accent,
    required this.accentBg,
    required this.accentGlow,
    required this.accentText,
  });

  final Color accent;
  final Color accentBg;
  final Color accentGlow;
  final Color accentText;

  /// Build from a raw accent color. Derives bg + glow automatically.
  factory AppAccentColors.fromAccent(Color accent) {
    return AppAccentColors(
      accent: accent,
      accentBg: accent.withOpacity(0.10),
      accentGlow: accent.withOpacity(0.25),
      accentText: _ensureLegible(accent),
    );
  }

  @override
  AppAccentColors copyWith({
    Color? accent,
    Color? accentBg,
    Color? accentGlow,
    Color? accentText,
  }) {
    return AppAccentColors(
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      accentGlow: accentGlow ?? this.accentGlow,
      accentText: accentText ?? this.accentText,
    );
  }

  @override
  AppAccentColors lerp(ThemeExtension<AppAccentColors>? other, double t) {
    if (other is! AppAccentColors) return this;
    return AppAccentColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
    );
  }

  /// Ensures the accent is bright enough to read on a dark background.
  static Color _ensureLegible(Color color) {
    final luminance = color.computeLuminance();
    if (luminance < 0.15) {
      // Lighten very dark accents
      return Color.lerp(color, const Color(0xFFFFFFFF), 0.4)!;
    }
    return color;
  }

  @override
  String toString() => 'AppAccentColors(accent: $accent)';
}

/// Convenience extension on BuildContext.
extension AppAccentColorsX on BuildContext {
  AppAccentColors get accentColors =>
      Theme.of(this).extension<AppAccentColors>()!;

  Color get accent => accentColors.accent;
  Color get accentBg => accentColors.accentBg;
  Color get accentGlow => accentColors.accentGlow;
  Color get accentText => accentColors.accentText;
}
