import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Palette - Deep Crimson / Maroon
  static const Color primary = Color(0xFFB71C1C);
  static const Color primaryDark = Color(0xFF8E0000);
  static const Color primaryLight = Color(0xFFD84315);

  // Accent / Gold
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5D076);
  static const Color goldDark = Color(0xFFB8860B);

  // Background
  static const Color scaffoldBg = Color(0xFFFFF8E7);
  static const Color cardBg = Colors.white;
  static const Color surfaceLight = Color(0xFFFFF3E0);

  // Text
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF795548);
  static const Color textOnPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color live = Color(0xFFE53935);
  static const Color info = Color(0xFF1565C0);

  // Borders / Dividers
  static const Color border = Color(0xFFE0D5C5);
  static const Color divider = Color(0xFFEDE0D0);

  // Chip colors
  static const Color chipSelected = Color(0xFFFBE9E7);
  static const Color chipBorder = Color(0xFFE0D5C5);

  // Bottom Nav
  static const Color navActive = Color(0xFFB71C1C);
  static const Color navInactive = Color(0xFF9E9E9E);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.cardBg,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textOnPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: AppColors.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
