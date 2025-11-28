import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/flexvault_colors.dart';

class FlexVaultTheme {
  FlexVaultTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlexVaultColors.tangerineDream,
        primary: FlexVaultColors.tangerineDream,
        secondary: FlexVaultColors.teaGreen,
        background: FlexVaultColors.vanillaCustard,
        surface: FlexVaultColors.lightYellow,
        error: FlexVaultColors.reddishBrown,
      ),
      scaffoldBackgroundColor: FlexVaultColors.vanillaCustard,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: FlexVaultColors.vanillaCustard,
        foregroundColor: FlexVaultColors.reddishBrown,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: FlexVaultColors.reddishBrown,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: FlexVaultColors.teaGreen,
        selectedColor: FlexVaultColors.tangerineDream,
        labelStyle: GoogleFonts.roboto(
          color: FlexVaultColors.reddishBrown,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlexVaultColors.lightYellow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.teaGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.teaGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.tangerineDream),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: FlexVaultColors.teaGreen,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: FlexVaultColors.lightYellow,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FlexVaultColors.tangerineDream,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlexVaultColors.tangerineDream,
        brightness: Brightness.dark,
        background: FlexVaultColors.darkBackground,
        surface: FlexVaultColors.darkSurface,
        primary: FlexVaultColors.tangerineDream,
        secondary: FlexVaultColors.teaGreen,
        error: FlexVaultColors.reddishBrown,
      ),
      scaffoldBackgroundColor: FlexVaultColors.darkBackground,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: FlexVaultColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardColor: FlexVaultColors.darkCard,
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF3A4A3A),
        selectedColor: const Color(0xFFB56E57),
        labelStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlexVaultColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.teaGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.teaGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlexVaultColors.tangerineDream),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: FlexVaultColors.teaGreen,
        unselectedItemColor: Colors.white70,
        backgroundColor: FlexVaultColors.darkSurface,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor =
        isDark ? Colors.white : FlexVaultColors.reddishBrown;
    final bodyColor = isDark ? Colors.white70 : Colors.black87;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: primaryColor,
        fontSize: 48,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        color: primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: bodyColor,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: bodyColor,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.roboto(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

