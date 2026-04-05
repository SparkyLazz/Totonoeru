// ─────────────────────────────────────────────────────────────────────────────
// APP SPACING & RADIUS
// All spatial tokens. Consistent with HTML prototype CSS variables.
// ─────────────────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;

  /// Standard horizontal screen padding
  static const double screenH = 20.0;

  /// Standard vertical top padding (below status bar)
  static const double screenTop = 16.0;

  /// Bottom nav bar height
  static const double bottomNavHeight = 80.0;

  /// FAB size
  static const double fabSize = 56.0;
}

class AppRadius {
  AppRadius._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double full = 999.0; // pill shape
}
