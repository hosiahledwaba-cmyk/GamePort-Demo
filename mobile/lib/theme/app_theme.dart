import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor:
          Colors.black, // Background handled by LiquidBackground
      // Modern Typography
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),

      // Glassy Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }
}
