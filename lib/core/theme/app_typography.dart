import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Inter';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.cream),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.cream),
        titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.cream),
        bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.cream),
        bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.cream),
        labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: AppColors.textMuted),
      );
}
