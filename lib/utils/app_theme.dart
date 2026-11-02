import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);
  static const Color accent = Color(0xFF4FACFE);
  static const Color accentSecondary = Color(0xFF00F2FE);
  static const Color onDay = Color(0xFF4FACFE);
  static const Color offDay = Color(0xFF3A3A5C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color danger = Color(0xFFFF4757);
  static const Color success = Color(0xFF2ED573);
  static const Color cardBorder = Color(0xFF2A2A4A);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          background: background,
          surface: surface,
          primary: accent,
          secondary: accentSecondary,
          error: danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return accent;
            return textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return accent.withOpacity(0.3);
            return offDay;
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.w200,
              letterSpacing: -2),
          headlineMedium: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500),
          bodyMedium:
              TextStyle(color: textSecondary, fontSize: 14),
          labelSmall: TextStyle(
              color: textSecondary,
              fontSize: 11,
              letterSpacing: 1.2),
        ),
      );
}
