import 'package:flutter/material.dart';
import 'mood_model.dart';

/// Strongly typed animation enum — prevents typos, enables exhaustive switches.
/// Each mood maps to exactly one animation style.
enum MoodAnimation {
  bounce,    // Happy — soft scale oscillation
  fade,      // Sad — slow opacity pulse
  pulse,     // Angry — gentle scale throb
  breathing, // Stressed — slow inhale/exhale motion
  floating,  // Relaxed — vertical drift
  upward,    // Motivated — gentle upward rise
}

/// Immutable configuration for a single mood's visual identity.
///
/// This is a data-only class — no business logic.
/// All instances are created and stored in [MoodThemeRepository].
class MoodThemeConfig {
  final MoodType mood;
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final List<Color> gradientColors;
  final MoodAnimation animation;
  final List<String> suggestedShortcuts;

  const MoodThemeConfig({
    required this.mood,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.gradientColors,
    required this.animation,
    this.suggestedShortcuts = const [],
  });

  /// A neutral config used when no mood is selected.
  /// Falls back to the app's default purple accent.
  static const MoodThemeConfig neutral = MoodThemeConfig(
    mood: MoodType.happy, // placeholder — not actually used
    accent: Color(0xFF624AC3),
    accentLight: Color(0xFFC5B8FF),
    accentDark: Color(0xFF9A83FF),
    gradientColors: [Color(0xFF624AC3), Color(0xFFC5B8FF)],
    animation: MoodAnimation.fade,
    suggestedShortcuts: [],
  );
}
