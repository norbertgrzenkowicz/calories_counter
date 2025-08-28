import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Huckberry-inspired color palette for adventure/travel
  static const Color primaryGreen = Color(0xFF2F5233); // Pine green
  static const Color forestGreen = Color(0xFF1B4332); // Darker forest green
  static const Color warmBrown = Color(0xFF8B4513); // Adventure brown
  static const Color creamWhite = Color(0xFFFAF7F2); // Warm cream
  static const Color softGray = Color(0xFFE8E5E0); // Light gray
  static const Color charcoal = Color(0xFF2C2C2C); // Dark text
  static const Color accentOrange = Color(0xFFD4811C); // Warm accent

  // Gradient definitions
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [creamWhite, softGray],
    stops: [0.0, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, forestGreen],
    stops: [0.0, 1.0],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        surface: creamWhite,
        background: creamWhite,
      ),

      // Custom typography with modern serif headlines and clean body text
      textTheme: TextTheme(
        // Headlines - Modern serif for sophistication
        displayLarge: GoogleFonts.crimsonText(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.crimsonText(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: charcoal,
        ),
        headlineMedium: GoogleFonts.crimsonText(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),

        // Body text - Clean and readable
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: charcoal,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: charcoal,
          height: 1.4,
        ),

        // Labels and captions
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: charcoal,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: charcoal.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),

      // Custom AppBar theme for macOS-like headers
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
      ),

      // Custom button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Custom input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: charcoal.withOpacity(0.5),
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: charcoal.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Custom card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: charcoal.withOpacity(0.08),
      ),
    );
  }
}
