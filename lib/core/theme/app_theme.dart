import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Medireflect AI Brand Colors (matching Figma / Untitled.zip)
  static const Color primaryTeal = Color(0xFF138A96);
  static const Color primaryTealDark = Color(0xFF0A5C67);
  static const Color primaryTealLight = Color(0xFF18A4B3);
  static const Color darkTeal = Color(0xFF0A5C67);
  static const Color accentCyan = Color(0xFF5EEAD4);
  static const Color accentMint = Color(0xFF5EEAD4);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color medicalBlue = Color(0xFF0284C7);

  // Background & Surface
  static const Color lightBackground = Color(0xFFF3F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color darkBackground = Color(0xFF0B1118);
  static const Color darkSurface = Color(0xFF151F2B);

  // Depth Level Colors (AMEE Guide 44)
  static const Color depthSuperficial = Color(0xFFEF4444);
  static const Color depthAnalytical = Color(0xFFF59E0B);
  static const Color depthTransformative = Color(0xFF10B981);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      secondary: accentCyan,
      surface: lightSurface,
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTealLight,
      primary: primaryTealLight,
      secondary: accentCyan,
      surface: darkSurface,
      background: darkBackground,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  );
}
