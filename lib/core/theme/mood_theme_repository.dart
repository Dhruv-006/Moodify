import 'package:flutter/material.dart';
import '../../models/mood_model.dart';
import '../../models/mood_theme_model.dart';

/// Central registry and single source of truth for all mood visual configurations.
///
/// Providers and UI request data from here — they never define theme configs.
/// To add a new mood, add a single entry to [_configs]. No other file needs changing.
class MoodThemeRepository {
  MoodThemeRepository._();
  static final MoodThemeRepository instance = MoodThemeRepository._();

  // ── Configuration Registry ──

  static const Map<MoodType, MoodThemeConfig> _configs = {
    MoodType.happy: MoodThemeConfig(
      mood: MoodType.happy,
      accent: Color(0xFFFBC02D),       // Warm Yellow
      accentLight: Color(0xFFFEF08A),
      accentDark: Color(0xFFFFCA28),    // Bright in dark mode
      gradientColors: [Color(0xFFFBC02D), Color(0xFFF57C00)], // Yellow → Orange
      animation: MoodAnimation.bounce,
      suggestedShortcuts: ['celebrate', 'share_joy', 'music'],
    ),
    MoodType.sad: MoodThemeConfig(
      mood: MoodType.sad,
      accent: Color(0xFF42A5F5),        // Soft Blue
      accentLight: Color(0xFFBBDEFB),
      accentDark: Color(0xFF64B5F6),
      gradientColors: [Color(0xFF42A5F5), Color(0xFF3F51B5)], // Blue → Indigo
      animation: MoodAnimation.fade,
      suggestedShortcuts: ['breathing', 'music', 'journal'],
    ),
    MoodType.angry: MoodThemeConfig(
      mood: MoodType.angry,
      accent: Color(0xFFC62828),        // Deep Red
      accentLight: Color(0xFFFFCDD2),
      accentDark: Color(0xFFEF5350),
      gradientColors: [Color(0xFFC62828), Color(0xFFE53935)], // Dark Red → Red
      animation: MoodAnimation.pulse,
      suggestedShortcuts: ['breathing', 'exercise', 'journal'],
    ),
    MoodType.stressed: MoodThemeConfig(
      mood: MoodType.stressed,
      accent: Color(0xFFF57C00),        // Orange
      accentLight: Color(0xFFFFE0B2),
      accentDark: Color(0xFFFFB74D),
      gradientColors: [Color(0xFFF57C00), Color(0xFFFFCC80)], // Orange → Soft Peach
      animation: MoodAnimation.breathing,
      suggestedShortcuts: ['breathing', 'relaxation_music', 'journal'],
    ),
    MoodType.relaxed: MoodThemeConfig(
      mood: MoodType.relaxed,
      accent: Color(0xFF43A047),        // Green
      accentLight: Color(0xFFC8E6C9),
      accentDark: Color(0xFF66BB6A),
      gradientColors: [Color(0xFF80CBC4), Color(0xFF43A047)], // Mint → Green
      animation: MoodAnimation.floating,
      suggestedShortcuts: ['meditation', 'gratitude_journal', 'nature'],
    ),
    MoodType.motivated: MoodThemeConfig(
      mood: MoodType.motivated,
      accent: Color(0xFF7B1FA2),        // Purple
      accentLight: Color(0xFFE1BEE7),
      accentDark: Color(0xFFAB47BC),
      gradientColors: [Color(0xFF7B1FA2), Color(0xFF3F51B5)], // Purple → Indigo
      animation: MoodAnimation.upward,
      suggestedShortcuts: ['goals', 'focus_music', 'achievements'],
    ),
  };

  // ── Public API ──

  /// Get the theme configuration for a specific mood.
  MoodThemeConfig getConfig(MoodType mood) {
    return _configs[mood] ?? MoodThemeConfig.neutral;
  }

  /// The neutral/default config when no mood is active.
  MoodThemeConfig get defaultConfig => MoodThemeConfig.neutral;

  /// All available mood theme configurations.
  List<MoodThemeConfig> get allConfigs => _configs.values.toList();

  /// Get the gradient for a specific mood.
  LinearGradient getGradient(MoodType mood, {bool isDark = false, double opacity = 1.0}) {
    final config = getConfig(mood);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: config.gradientColors.map((c) {
        final base = isDark ? _lightenForDark(c) : c;
        return base.withValues(alpha: opacity);
      }).toList(),
    );
  }

  /// Get a subtle gradient for card backgrounds.
  LinearGradient getSubtleGradient(MoodType mood, {double opacity = 0.15}) {
    return getGradient(mood, opacity: opacity);
  }

  /// Get the animation type for a specific mood.
  MoodAnimation getAnimation(MoodType mood) {
    return _configs[mood]?.animation ?? MoodAnimation.fade;
  }

  /// Lighten a color for dark mode visibility.
  static Color _lightenForDark(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
  }
}
