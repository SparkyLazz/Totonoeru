import 'package:flutter/material.dart';

/// All color tokens for Totonoeru.
/// Organized by role: background, surface, border, text, accent presets.
abstract final class AppColors {
  // ── Light Mode Background ─────────────────────────────────────────────────
  static const backgroundLight = Color(0xFFF4F3F0);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF8F7F4);
  static const borderLight = Color(0xFFE5E4E0);
  static const borderSubtleLight = Color(0xFFF0EFEc);

  // ── Dark Mode Background ──────────────────────────────────────────────────
  static const backgroundDark = Color(0xFF0F0F0E);
  static const surfaceDark = Color(0xFF1A1A18);
  static const surfaceElevatedDark = Color(0xFF232321);
  static const borderDark = Color(0xFF2C2C29);
  static const borderSubtleDark = Color(0xFF242422);

  // ── Text — Light Mode ─────────────────────────────────────────────────────
  static const textPrimaryLight = Color(0xFF1A1A18);    // headings
  static const textSecondaryLight = Color(0xFF6B6B67);  // body
  static const textTertiaryLight = Color(0xFF9C9C97);   // captions
  static const textDisabledLight = Color(0xFFBFBFBA);   // disabled

  // ── Text — Dark Mode ─────────────────────────────────────────────────────
  static const textPrimaryDark = Color(0xFFF4F3F0);
  static const textSecondaryDark = Color(0xFFA8A8A3);
  static const textTertiaryDark = Color(0xFF6B6B67);
  static const textDisabledDark = Color(0xFF404040);

  // ── Priority Colors ───────────────────────────────────────────────────────
  static const priorityHigh = Color(0xFFE24B4A);    // Red
  static const priorityMedium = Color(0xFFEF9F27);  // Amber
  static const priorityLow = Color(0xFF4A90D9);     // Blue

  static const priorityHighBg = Color(0x1AE24B4A);
  static const priorityMediumBg = Color(0x1AEF9F27);
  static const priorityLowBg = Color(0x1A4A90D9);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const statusDone = Color(0xFF1D9E75);
  static const statusInProgress = Color(0xFF4A90D9);
  static const statusPending = Color(0xFF9C9C97);
  static const statusArchived = Color(0xFFBFBFBA);

  // ── 6 Accent Presets (task 1.05 + D06) ──────────────────────────────────
  static const accentTeal = Color(0xFF1D9E75);     // default
  static const accentBlue = Color(0xFF4A90D9);
  static const accentPurple = Color(0xFF7F77DD);
  static const accentRed = Color(0xFFE24B4A);
  static const accentAmber = Color(0xFFEF9F27);
  static const accentCoral = Color(0xFFD44C3A);

  static const List<Color> accentPresets = [
    accentTeal,
    accentBlue,
    accentPurple,
    accentRed,
    accentAmber,
    accentCoral,
  ];

  static const List<String> accentPresetHex = [
    '#1D9E75',
    '#4A90D9',
    '#7F77DD',
    '#E24B4A',
    '#EF9F27',
    '#D44C3A',
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns accent color from hex string. Falls back to teal.
  static Color accentFromHex(String hex) {
    try {
      final sanitized = hex.replaceAll('#', '');
      return Color(int.parse('FF$sanitized', radix: 16));
    } catch (_) {
      return accentTeal;
    }
  }

  /// Returns hex string from Color (e.g. '#1D9E75').
  static String hexFromColor(Color color) {
    return '#${color.value.toRadixString(16).toUpperCase().substring(2)}';
  }
}
