import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  /// 🌞 LIGHT THEME
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffF5F5F7),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff007AFF),
      brightness: Brightness.light,
    ),

    cardColor: Colors.white,

    textTheme: TextTheme(
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xff1D1D1F),
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: const Color(0xff1D1D1F),
      ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color(0xff1D1D1F),
      ),
      iconTheme: const IconThemeData(color: Color(0xff1D1D1F)),
    ),
  );

  /// 🌙 DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff007AFF),
      brightness: Brightness.dark,
    ),

    cardColor: const Color(0xff1E1E1E),

    textTheme: TextTheme(
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  );
}