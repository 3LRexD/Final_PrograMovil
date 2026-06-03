import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFF3E600);//amarillo neon
  static const Color secondary = Color(0xFF00E6E6);//celeste neon
  static const Color accentRed = Color(0xFFFF0033);//rojo brillante
  static const Color background = Color(0xFF0F0F13);//gris oscuro de fondo
  static const Color surface = Color(0xFF1A1A24);//gris mas claro para paneles

  static ThemeData get cyberpunk => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
          error: accentRed,
          onPrimary: Colors.black, 
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.rajdhaniTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white70,
          displayColor: primary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: primary,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.rajdhani(
            color: primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            textStyle: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: secondary,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            textStyle: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: surface,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          elevation: 0,
        ),
      );
}
