import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_accent_colors.dart';

/// Builds MaterialApp ThemeData for light and dark modes.
/// Call [AppTheme.buildTheme] in MaterialApp / MaterialApp.router.
abstract final class AppTheme {
  static ThemeData buildTheme(Color accent, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final bg = isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    final surface = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final surfaceElevated = isLight
        ? AppColors.surfaceElevatedLight
        : AppColors.surfaceElevatedDark;
    final border = isLight ? AppColors.borderLight : AppColors.borderDark;
    final textPrimary =
    isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final textSecondary =
    isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    final accentExt = AppAccentColors.fromAccent(accent);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: _onAccent(accent),
        secondary: accent,
        onSecondary: _onAccent(accent),
        error: AppColors.priorityHigh,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: AppTypography.buildTextTheme(textPrimary, textSecondary),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentExt.accentBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 22);
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(color: accent);
          }
          return AppTypography.labelSmall.copyWith(color: textSecondary);
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        side: BorderSide(color: border),
        labelStyle: AppTypography.labelMedium.copyWith(color: textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
      ),
      extensions: [accentExt],
    );
  }

  /// Returns white or dark text depending on accent brightness.
  static Color _onAccent(Color accent) {
    return accent.computeLuminance() > 0.35
        ? const Color(0xFF1A1A18)
        : Colors.white;
  }
}