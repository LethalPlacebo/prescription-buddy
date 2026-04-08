import 'package:flutter/material.dart';

class AppTheme {
  static const Color cream = Color(0xFFFDF8F1);
  static const Color warm = Color(0xFFF5EEDD);
  static const Color card = Color(0xF2FFF9F1);
  static const Color ink = Color(0xFF1E293B);
  static const Color muted = Color(0xFF667085);
  static const Color emerald = Color(0xFF146356);
  static const Color emeraldDeep = Color(0xFF0C3D35);
  static const Color gold = Color(0xFFD7A545);
  static const Color goldSoft = Color(0xFFF7E8C5);
  static const Color rose = Color(0xFFF6D8D6);
  static const Color shadow = Color(0x29111B2A);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.light,
        primary: emerald,
        secondary: gold,
        surface: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: ink,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: const TextStyle(fontSize: 15, height: 1.5, color: muted),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.5, color: muted),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
