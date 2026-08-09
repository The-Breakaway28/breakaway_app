import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final textTheme = AppTypography.textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.emeraldDeep,
      fontFamily: textTheme.bodyLarge?.fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.emeraldDeep,
        primary: AppColors.neon,
        onPrimary: AppColors.emeraldDeep,
        secondary: AppColors.cream,
        error: AppColors.error,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.emeraldSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: textTheme.labelLarge,
        hintStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.emeraldLine, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.emeraldLine, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.neon, width: 1.4)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.error, width: 1.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neon,
          foregroundColor: AppColors.emeraldDeep,
          disabledBackgroundColor: AppColors.neonDisabled,
          disabledForegroundColor: AppColors.emeraldDeep.withOpacity(0.5),
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.emeraldDeep, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, textStyle: textTheme.bodyMedium),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.neon, linearTrackColor: AppColors.emeraldLine),
      dividerTheme: const DividerThemeData(color: AppColors.emeraldLine, thickness: 1, space: 32),
    );
  }
}
