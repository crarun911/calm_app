import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette — deep midnight with warm sage and gold accents
  static const Color midnight = Color(0xFF0D1117);
  static const Color deepNavy = Color(0xFF141B2D);
  static const Color cardSurface = Color(0xFF1C2640);
  static const Color cardSurface2 = Color(0xFF1A2235);
  static const Color sage = Color(0xFF7CB9A0);
  static const Color sageLight = Color(0xFFA8D5C2);
  static const Color gold = Color(0xFFD4A853);
  static const Color goldLight = Color(0xFFE8C57A);
  static const Color lavender = Color(0xFF9B8EC4);
  static const Color lavenderLight = Color(0xFFBBAFD9);
  static const Color rose = Color(0xFFE07A8F);
  static const Color textPrimary = Color(0xFFF0EDE8);
  static const Color textSecondary = Color(0xFF8A9BB5);
  static const Color textMuted = Color(0xFF4A5568);
  static const Color divider = Color(0xFF243049);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnight,
      colorScheme: const ColorScheme.dark(
        primary: sage,
        secondary: gold,
        surface: cardSurface,
        onPrimary: midnight,
        onSecondary: midnight,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ),
        headlineLarge: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: deepNavy,
        selectedItemColor: sage,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Gradient presets
  static const LinearGradient midnightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1117), Color(0xFF141B2D)],
  );

  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A9B82), Color(0xFF2E7A63)],
  );

  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1035), Color(0xFF2D1B69), Color(0xFF0D1117)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A853), Color(0xFFB8863A)],
  );

  static const LinearGradient roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE07A8F), Color(0xFFB85470)],
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowSage = [
    BoxShadow(
      color: sage.withOpacity(0.25),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> glowGold = [
    BoxShadow(
      color: gold.withOpacity(0.3),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];
}
