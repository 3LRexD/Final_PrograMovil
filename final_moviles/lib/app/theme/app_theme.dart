import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFF1976D2);
  static const Color background = Color(0xFFF5F5F5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      );
}
