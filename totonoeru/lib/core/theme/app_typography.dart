import 'package:flutter/material.dart';

/// Typography tokens for Totonoeru.
/// DM Sans 300/400/500/600 · DM Mono 400/500 · Noto Sans JP 300/400/500
abstract final class AppTypography {
  // ── Font Families ─────────────────────────────────────────────────────────
  static const fontSans = 'DMSans';
  static const fontMono = 'DMMono';
  static const fontJP = 'NotoSansJP';

  // ── DM Sans Display ───────────────────────────────────────────────────────
  static const displayLarge = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── DM Sans Headings ─────────────────────────────────────────────────────
  static const headingLarge = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const headingMedium = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const headingSmall = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── DM Sans Body ─────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    letterSpacing: 0,
    height: 1.45,
  );

  // ── DM Sans Labels ────────────────────────────────────────────────────────
  static const labelLarge = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const labelSmall = TextStyle(
    fontFamily: fontSans,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // ── DM Mono ───────────────────────────────────────────────────────────────
  static const monoLarge = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.3,
    height: 1.4,
  );

  static const monoMedium = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const monoSmall = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // Timer / large numeric display
  static const timerDisplay = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    fontSize: 64,
    letterSpacing: -2,
    height: 1.0,
  );

  // ── Noto Sans JP ──────────────────────────────────────────────────────────
  static const jpLight = TextStyle(
    fontFamily: fontJP,
    fontWeight: FontWeight.w300,
    fontSize: 13,
    height: 1.5,
  );

  static const jpRegular = TextStyle(
    fontFamily: fontJP,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
  );

  static const jpMedium = TextStyle(
    fontFamily: fontJP,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.5,
  );

  // ── Build TextTheme for MaterialApp ──────────────────────────────────────
  static TextTheme buildTextTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: textPrimary),
      displayMedium: displayMedium.copyWith(color: textPrimary),
      headlineLarge: headingLarge.copyWith(color: textPrimary),
      headlineMedium: headingMedium.copyWith(color: textPrimary),
      headlineSmall: headingSmall.copyWith(color: textPrimary),
      bodyLarge: bodyLarge.copyWith(color: textSecondary),
      bodyMedium: bodyMedium.copyWith(color: textSecondary),
      bodySmall: bodySmall.copyWith(color: textSecondary),
      labelLarge: labelLarge.copyWith(color: textPrimary),
      labelMedium: labelMedium.copyWith(color: textSecondary),
      labelSmall: labelSmall.copyWith(color: textSecondary),
    );
  }
}
