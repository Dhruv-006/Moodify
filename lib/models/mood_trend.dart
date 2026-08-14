import 'mood_model.dart';

/// Result of analyzing recent mood history.
///
/// Produced by [MoodTrendService], consumed by UI for adaptive messaging.
class MoodTrend {
  /// The most frequently logged mood in the analysis window.
  final MoodType? dominantMood;

  /// High-level category: 'positive', 'negative', 'stressed', 'mixed'.
  final String trendCategory;

  /// A short insight message for the Insights page.
  /// e.g. "You've had a positive week. Keep building on these moments."
  final String insightMessage;

  /// An empathetic message for prolonged patterns, shown on the Home screen.
  /// e.g. "You've been carrying a lot lately. Consider a small break."
  final String adaptiveMessage;

  /// Prioritized list of recommended actions based on the trend.
  /// e.g. ['breathing', 'relaxation_music', 'journaling']
  final List<String> recommendations;

  /// True if the user shows a prolonged negative emotional pattern.
  final bool isStruggling;

  /// Total number of entries analyzed.
  final int totalEntries;

  const MoodTrend({
    this.dominantMood,
    required this.trendCategory,
    required this.insightMessage,
    required this.adaptiveMessage,
    required this.recommendations,
    this.isStruggling = false,
    this.totalEntries = 0,
  });

  /// Default trend when there is insufficient data.
  static const MoodTrend empty = MoodTrend(
    trendCategory: 'mixed',
    insightMessage: 'Start logging moods to discover your emotional patterns.',
    adaptiveMessage: '',
    recommendations: [],
    totalEntries: 0,
  );

  bool get hasData => totalEntries > 0;
}
