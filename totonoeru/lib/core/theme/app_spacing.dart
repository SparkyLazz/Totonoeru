/// Spacing constants for Totonoeru.
/// Usage: SizedBox(height: AppSpacing.md) or Gap(AppSpacing.md)
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // ── Named Semantic Aliases ─────────────────────────────────────────────
  static const double pagePadding = base;
  static const double cardPadding = base;
  static const double sectionGap = xl;
  static const double itemGap = sm;
  static const double chipGap = xs;
}
