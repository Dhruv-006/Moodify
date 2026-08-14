import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors from HTML design
  static const Color primary = Color(0xFF624AC3);
  static const Color primaryContainer = Color(0xFFC5B8FF);
  static const Color onPrimary = Color(0xFFFCF7FF);
  static const Color onPrimaryContainer = Color(0xFF3F209E);

  static const Color secondary = Color(0xFF0060AC);
  static const Color secondaryContainer = Color(0xFFD3E3FF);

  static const Color tertiary = Color(0xFF3B6943);
  static const Color tertiaryContainer = Color(0xFFCAFECD);

  static const Color error = Color(0xFFAC3149);
  static const Color errorContainer = Color(0xFFF76A80);

  static const Color surface = Color(0xFFFDF8FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2F9);
  static const Color surfaceContainer = Color(0xFFF1ECF4);
  static const Color surfaceContainerHigh = Color(0xFFEBE6EF);
  static const Color surfaceContainerHighest = Color(0xFFE5E1EB);

  static const Color onSurface = Color(0xFF333139);
  static const Color onSurfaceVariant = Color(0xFF605E66);
  static const Color outline = Color(0xFF7C7982);
  static const Color outlineVariant = Color(0xFFB4B0BA);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainerHigh = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Color(0xFFE5E1EB);
  static const Color darkOnSurfaceVariant = Color(0xFFB4B0BA);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.light(
      primary: primary,
      primaryContainer: primaryContainer,
      onPrimary: onPrimary,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      error: error,
      errorContainer: errorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(color: onSurface),
        bodyMedium: GoogleFonts.manrope(color: onSurfaceVariant),
        labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.manrope(
          color: onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        indicatorColor: primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: primary,
        labelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF9A83FF),
      primaryContainer: const Color(0xFF482CA7),
      onPrimary: const Color(0xFF290082),
      onPrimaryContainer: primaryContainer,
      secondary: const Color(0xFFBCD6FF),
      secondaryContainer: const Color(0xFF005396),
      tertiary: const Color(0xFFBCEFBF),
      tertiaryContainer: const Color(0xFF37643E),
      error: errorContainer,
      errorContainer: const Color(0xFF68001F),
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: const Color(0xFF7C7982),
      outlineVariant: const Color(0xFF605E66),
      surfaceContainerLowest: const Color(0xFF0E0E11),
      surfaceContainerLow: const Color(0xFF1A1A1E),
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: const Color(0xFF363636),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkSurface,
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: darkOnSurface,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: darkOnSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        bodyLarge: GoogleFonts.manrope(color: darkOnSurface),
        bodyMedium: GoogleFonts.manrope(color: darkOnSurfaceVariant),
        labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: darkOnSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF9A83FF),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9A83FF)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A83FF),
          foregroundColor: const Color(0xFF290082),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.manrope(
          color: darkOnSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceContainer.withValues(alpha: 0.8),
        selectedItemColor: const Color(0xFF9A83FF),
        unselectedItemColor: const Color(0xFF605E66),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceContainerHigh,
        selectedColor: const Color(0xFF9A83FF),
        labelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
