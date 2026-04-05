import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_accent_colors.dart';
import '../constants/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP THEME
// Builds complete ThemeData for light + dark modes.
// accentColor is injected from the Riverpod provider (Decision 4).
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData light(Color accentColor) {
    final accent = AppAccentColors.fromAccent(accentColor);
    return _buildTheme(
      brightness: Brightness.light,
      bg: AppColors.lightBg,
      surface: AppColors.lightSurface,
      surface2: AppColors.lightSurface2,
      border: AppColors.lightBorder,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textTertiary: AppColors.lightTextTertiary,
      accent: accent,
      statusBarBrightness: Brightness.dark,
    );
  }

  static ThemeData dark(Color accentColor) {
    final accent = AppAccentColors.fromAccent(accentColor);
    return _buildTheme(
      brightness: Brightness.dark,
      bg: AppColors.darkBg,
      surface: AppColors.darkSurface,
      surface2: AppColors.darkSurface2,
      border: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textTertiary: AppColors.darkTextTertiary,
      accent: accent,
      statusBarBrightness: Brightness.light,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surface2,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required AppAccentColors accent,
    required Brightness statusBarBrightness,
  }) {
    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      extensions: [accent],
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: accent.accent,
        secondary: accent.accent,
        surface: surface,
        background: bg,
        outline: border,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingS.copyWith(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: statusBarBrightness,
          statusBarIconBrightness: statusBarBrightness,
          systemNavigationBarColor: surface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.headingL.copyWith(color: textPrimary),
        displayMedium: AppTextStyles.headingM.copyWith(color: textPrimary),
        displaySmall: AppTextStyles.headingS.copyWith(color: textPrimary),
        bodyLarge: AppTextStyles.bodyL.copyWith(color: textPrimary),
        bodyMedium: AppTextStyles.bodyM.copyWith(color: textSecondary),
        bodySmall: AppTextStyles.bodyS.copyWith(color: textTertiary),
        labelSmall: AppTextStyles.labelXS.copyWith(color: textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: accent.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: accent.accentBg,
        labelStyle: AppTextStyles.bodyS.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: border),
        ),
        showCheckmark: false,
      ),
    );
  }
}
