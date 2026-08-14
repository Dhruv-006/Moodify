import 'package:flutter/material.dart';
import '../../models/mood_theme_model.dart';

/// Applies a mood accent layer on top of existing Light/Dark [ThemeData].
///
/// Only overrides accent-related properties (primary, primaryContainer, etc.).
/// Surface, background, and text colors remain completely untouched.
class AdaptiveTheme {
  AdaptiveTheme._();

  /// Apply mood accent colors to an existing [ThemeData].
  ///
  /// The [base] theme (light or dark) retains its surface/background colors.
  /// Only accent-related properties are overridden with [config] colors.
  static ThemeData applyMoodAccent(ThemeData base, MoodThemeConfig config) {
    // If this is the neutral config, return the base theme unchanged
    if (config == MoodThemeConfig.neutral) return base;

    final isDark = base.brightness == Brightness.dark;
    final accent = isDark ? config.accentDark : config.accent;
    final accentContainer = isDark
        ? config.accent.withValues(alpha: 0.3)
        : config.accentLight;
    final onAccentContainer = isDark ? config.accentLight : config.accent;

    // Override only accent-related slots in the ColorScheme
    final newScheme = base.colorScheme.copyWith(
      primary: accent,
      primaryContainer: accentContainer,
      onPrimaryContainer: onAccentContainer,
    );

    return base.copyWith(
      colorScheme: newScheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: accent,
        ),
        iconTheme: IconThemeData(color: accent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          backgroundColor: WidgetStatePropertyAll(accent),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: accent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: base.colorScheme.onPrimary,
      ),
    );
  }
}
