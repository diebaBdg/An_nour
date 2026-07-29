import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: brightness,
      primary: AppColors.emerald,
      secondary: AppColors.gold,
      surface: isDark ? AppColors.darkSurface : AppColors.offWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.charcoal : AppColors.offWhite,
      textTheme: _textTheme(isDark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? AppColors.darkCard : AppColors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.emerald.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.emerald,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    final baseColor =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.6,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
    );
  }
}
