import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP TEXT STYLES
// DM Sans (primary) · DM Mono (numbers/timer) · Noto Sans JP (JP labels)
// Decision 2 — DM Sans locked as primary font.
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // ── DM SANS ──────────────────────────────────────────────────────────────

  /// 28px / SemiBold — Screen titles, greeting header
  static const TextStyle headingL = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 22px / SemiBold — Section headings, card titles
  static const TextStyle headingM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  /// 18px / SemiBold — Sub-headings
  static const TextStyle headingS = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// 16px / Medium — Body, task titles
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// 14px / Regular — Body secondary, metadata
  static const TextStyle bodyM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 12px / Regular — Labels, tags, small text
  static const TextStyle bodyS = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// 11px / Medium — Tiny labels, bottom nav
  static const TextStyle labelXS = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // ── DM MONO ──────────────────────────────────────────────────────────────

  /// 48px / Medium — Focus timer display
  static const TextStyle timerXL = TextStyle(
    fontFamily: 'DMMono',
    fontSize: 48,
    fontWeight: FontWeight.w500,
    letterSpacing: -1,
    height: 1.0,
  );

  /// 20px / Regular — Stats numbers, char counts
  static const TextStyle monoL = TextStyle(
    fontFamily: 'DMMono',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  /// 14px / Regular — Inline numbers, timestamps
  static const TextStyle monoM = TextStyle(
    fontFamily: 'DMMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ── NOTO SANS JP ─────────────────────────────────────────────────────────

  /// 12px / Light — Japanese subtitle labels (タスク一覧, 今日の予定 etc.)
  static const TextStyle jpSubtitle = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    height: 1.4,
  );

  /// 10px / Regular — Tiny JP labels
  static const TextStyle jpXS = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
  );
}
