import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // The Kinetic Monolith palette
  static const Color darkBackground = Color(0xFF0A0A0A); // The void
  static const Color surface = Color(0xFF131313); // Primary canvas
  static const Color surfaceContainerLow = Color(0xFF1C1B1B); // Subtle sectioning
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A); // Elevated cards
  static const Color cardBackground = Color(0xFF1C1B1B); // Aligned with surfaceContainerLow
  static const Color borderColor = Color(0xFF2A2A2A); // Subtle borders
  static const Color textPrimary = Color(0xFFE5E2E1); // NO pure white
  static const Color textSecondary = Color(0xFFB0B0B0); // Gray text
  static const Color textTertiary = Color(0xFF707070); // Dimmed text

  // Bright sporty accent colors - used sparingly for macros/goals
  static const Color neonRed = Color(0xFFFF0055); // Protein
  static const Color neonYellow = Color(0xFFFFFF00); // Carbs
  static const Color neonBlue = Color(0xFF00E5FF); // Fats
  static const Color neonGreen = Color(0xFF00FF88); // Success/Calories - primary accent
  static const Color neonOrange = Color(0xFFFF6B00); // Warning

  // Gradient definitions
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBackground, Color(0xFF0F0F0F)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2A2A), Color(0xFF1F1F1F)],
    stops: [0.0, 1.0],
  );

  // Spacing constants
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;

  /// Monospace style for data readouts (calories, macros, numbers).
  /// Feels like a terminal readout.
  static TextStyle monoStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = textPrimary,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Neon glow box shadow for primary action buttons.
  static List<BoxShadow> neonGlowShadow({double blurRadius = 12, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: neonGreen.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: neonGreen,
        onPrimary: const Color(0xFF003919),
        secondary: neonGreen,
        onSecondary: const Color(0xFF003919),
        error: neonRed,
        onError: darkBackground,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
        outline: borderColor,
        outlineVariant: Color(0xFF2A2A2A),
      ),
      scaffoldBackgroundColor: darkBackground,

      // Custom typography - Inter for all text
      textTheme: TextTheme(
        // Headlines - tight letter-spacing, heavy and authoritative
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.64, // -0.02em at 32px
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.56, // -0.02em at 28px
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.48, // -0.02em at 24px
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4, // -0.02em at 20px
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.32,
        ),

        // Body text - breathing room with secondary color
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textTertiary,
          height: 1.4,
        ),

        // Labels and captions
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.28,
        ),
      ),

      // AppBar - transparent, editorial
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.08,
        ),
      ),

      // Elevated button - neon green with glow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: const Color(0xFF003919),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Silent input style: no fill, no outline, only bottom border ghost
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: borderColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: borderColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: neonGreen,
            width: 1.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: neonRed.withOpacity(0.6),
            width: 1,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: neonRed,
            width: 1.5,
          ),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.inter(
          color: textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: neonGreen,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card theme - xl radius (24px), no elevation, no borders
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: surfaceContainerLow,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textPrimary),

      // No dividers - background shifts create separation
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
      ),

      // Popup menu
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
        ),
      ),

      // ChoiceChip / chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHigh,
        selectedColor: neonGreen,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF003919),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
      ),
    );
  }
}
