import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Brand fallback seed color for older Android versions (Android 10 & 11)
  static const Color brandSeedColor = Color(0xFF3FBF9F);

  // ─── Light Theme ──────────────────────────────────────────────────────────
  // On Android 12+: DynamicColorBuilder passes wallpaper-based colors here.
  //   harmonized() blends those colors toward our brand green so the app
  //   stays coherent with the system while keeping brand identity.
  // On Android 10–11: dynamicColorScheme is null → falls back to
  //   ColorScheme.fromSeed(brandSeedColor) which generates all tonal
  //   palette entries purely from our green.
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    final baseScheme =
        dynamicColorScheme?.harmonized() ??
        ColorScheme.fromSeed(
          seedColor: brandSeedColor,
          brightness: Brightness.light,
        );

    // Lock primary & primaryContainer to brand green tones.
    // Everything else (surface tones, outlines) stays dynamic when available,
    // so the app still feels native to each device.
    final scheme = baseScheme.copyWith(
      primary: brandSeedColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD7F5EC),   // soft mint — replaces any blue container
      onPrimaryContainer: const Color(0xFF00382B), // deep green for readable icons/text inside
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF9FBFA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: const Color(0xFFF9FBFA),
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      // Primary action button — always brand green
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandSeedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      // Text buttons (e.g. "Use my location" in Checkout) — brand green
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandSeedColor,
        ),
      ),
      // Outlined buttons — brand green border & label
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandSeedColor,
          side: const BorderSide(color: brandSeedColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  // Same dynamic-color strategy as light theme, but all surface/text colors
  // are explicitly set to charcoal tones for eye comfort and contrast.
  // Dynamic wallpaper tones do NOT bleed into dark surfaces — only
  // primary is brand-locked, giving a consistent premium dark look.
  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    final baseScheme =
        dynamicColorScheme?.harmonized() ??
        ColorScheme.fromSeed(
          seedColor: brandSeedColor,
          brightness: Brightness.dark,
        );

    // Explicit overrides: charcoal surfaces + lighter brand green for contrast
    final scheme = baseScheme.copyWith(
      primary: const Color(0xFF4ED8B4),            // lighter green readable on dark bg
      onPrimary: const Color(0xFF00382B),
      primaryContainer: const Color(0xFF1A4A3C),   // deep green container — no blue
      onPrimaryContainer: const Color(0xFFB7EFDF),
      surface: const Color(0xFF262B30),
      onSurface: const Color(0xFFF1F5F9),
      surfaceContainerHighest: const Color(0xFF343B42),
      onSurfaceVariant: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFF475569),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      // Soft charcoal background — eye comfort instead of pure black
      scaffoldBackgroundColor: const Color(0xFF1C2024),
      cardTheme: CardThemeData(
        color: const Color(0xFF262B30),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF384048), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF1C2024),
        foregroundColor: Color(0xFFF1F5F9),
        elevation: 0,
      ),
      // Clean, high-contrast typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFF1F5F9)),
        displayMedium: TextStyle(color: Color(0xFFF1F5F9)),
        displaySmall: TextStyle(color: Color(0xFFF1F5F9)),
        headlineLarge: TextStyle(color: Color(0xFFF1F5F9)),
        headlineMedium: TextStyle(color: Color(0xFFF1F5F9)),
        headlineSmall: TextStyle(color: Color(0xFFF1F5F9)),
        titleLarge: TextStyle(color: Color(0xFFF1F5F9)),
        titleMedium: TextStyle(color: Color(0xFFF1F5F9)),
        titleSmall: TextStyle(color: Color(0xFFF1F5F9)),
        bodyLarge: TextStyle(color: Color(0xFFF1F5F9)),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        bodySmall: TextStyle(color: Color(0xFFCBD5E1)),
        labelLarge: TextStyle(color: Color(0xFFF1F5F9)),
        labelMedium: TextStyle(color: Color(0xFFCBD5E1)),
        labelSmall: TextStyle(color: Color(0xFFCBD5E1)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262B30),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF384048)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF384048)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ED8B4), width: 1.5),
        ),
      ),
      // Buttons in dark mode use lighter brand green for sufficient contrast
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4ED8B4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4ED8B4),
          side: const BorderSide(color: Color(0xFF4ED8B4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
