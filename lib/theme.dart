import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A7CFF);
  static const Color accent = Color(0xFFE0245E);
  static ThemeData light() {
    // Minimal safe theme: avoid using APIs that may vary across SDKs at runtime.
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
