import 'package:flutter/material.dart';

/// Border radius tokens for Totonoeru.
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // ── BorderRadius Shortcuts ─────────────────────────────────────────────
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // ── Card / Sheet bottom sheet ──────────────────────────────────────────
  static const BorderRadius card = radiusMd;
  static const BorderRadius sheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
  static const BorderRadius chip = radiusFull;
  static const BorderRadius button = radiusMd;
  static const BorderRadius tag = radiusSm;
}
