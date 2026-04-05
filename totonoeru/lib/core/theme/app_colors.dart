import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP COLORS
// Single source of truth. Never hardcode hex values outside this file.
// All colors match the HTML prototype CSS variables exactly.
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── ACCENT PRESETS (Decision 4 — 6 locked presets for v1.0) ─────────────
  static const Color accentTeal   = Color(0xFF1D9E75); // default
  static const Color accentBlue   = Color(0xFF4A90D9);
  static const Color accentPurple = Color(0xFF7F77DD);
  static const Color accentRed    = Color(0xFFE24B4A);
  static const Color accentAmber  = Color(0xFFEF9F27);
  static const Color accentCoral  = Color(0xFFD44C3A);

  static const List<Color> accentPresets = [
    accentTeal,
    accentBlue,
    accentPurple,
    accentRed,
    accentAmber,
    accentCoral,
  ];

  // ── LIGHT THEME ──────────────────────────────────────────────────────────
  static const Color lightBg          = Color(0xFFF4F3F0); // --bg
  static const Color lightSurface     = Color(0xFFFFFFFF); // --surface
  static const Color lightSurface2    = Color(0xFFF0EFEb); // --surface-2
  static const Color lightBorder      = Color(0xFFE5E4E0); // --border
  static const Color lightTextPrimary = Color(0xFF1A1A18); // --text-primary
  static const Color lightTextSecondary = Color(0xFF6B6B66); // --text-secondary
  static const Color lightTextTertiary  = Color(0xFF9E9E99); // --text-tertiary

  // ── DARK THEME ───────────────────────────────────────────────────────────
  static const Color darkBg           = Color(0xFF0F0F0E); // --bg
  static const Color darkSurface      = Color(0xFF1A1A18); // --surface
  static const Color darkSurface2     = Color(0xFF242422); // --surface-2
  static const Color darkBorder       = Color(0xFF2E2E2B); // --border
  static const Color darkTextPrimary  = Color(0xFFF0EFEb); // --text-primary
  static const Color darkTextSecondary = Color(0xFF9E9E99); // --text-secondary
  static const Color darkTextTertiary  = Color(0xFF6B6B66); // --text-tertiary

  // ── PRIORITY COLORS ──────────────────────────────────────────────────────
  static const Color priorityHigh   = Color(0xFFE24B4A);
  static const Color priorityMedium = Color(0xFFEF9F27);
  static const Color priorityLow    = Color(0xFF6B6B66);

  // ── CATEGORY DEFAULTS ────────────────────────────────────────────────────
  static const Color categoryWork     = Color(0xFF4A90D9);
  static const Color categoryPersonal = Color(0xFF1D9E75);
  static const Color categoryStudy    = Color(0xFF7F77DD);
  static const Color categoryHealth   = Color(0xFFE24B4A);
  static const Color categoryBreak    = Color(0xFFEF9F27);

  // ── STATUS ───────────────────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF1D9E75);
  static const Color statusWarning = Color(0xFFEF9F27);
  static const Color statusError   = Color(0xFFE24B4A);
}
