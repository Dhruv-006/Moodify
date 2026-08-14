import '../models/mood_model.dart';
import '../models/mood_trend.dart';

/// Analyzes recent mood history to detect emotional patterns and generate
/// intelligent, empathetic recommendations.
///
/// Improvement #3: Extracted from provider — pure business logic, no Flutter deps.
/// Improvement #6: Adaptive emotional intelligence based on history.
/// Improvement #8: Async interface for future AI provider compatibility.
class MoodTrendService {
  static const _positiveSet = {MoodType.happy, MoodType.relaxed, MoodType.motivated};
  static const _negativeSet = {MoodType.sad, MoodType.angry, MoodType.stressed};

  /// Analyze the given entries (typically last 7 days) and produce a [MoodTrend].
  MoodTrend analyze(List<MoodEntry> entries) {
    if (entries.isEmpty) return MoodTrend.empty;

    // Count mood frequencies
    final counts = <MoodType, int>{};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }

    // Find dominant mood
    final dominantEntry = counts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final dominantMood = dominantEntry.key;

    // Calculate positive vs negative ratio
    int positiveCount = 0;
    int negativeCount = 0;
    for (final e in entries) {
      if (_positiveSet.contains(e.mood)) {
        positiveCount++;
      } else {
        negativeCount++;
      }
    }

    // Detect prolonged patterns (3+ same-category entries in 5 recent)
    final recent = entries.length >= 5 ? entries.sublist(0, 5) : entries;
    final recentNegative = recent.where((e) => _negativeSet.contains(e.mood)).length;
    final recentStressed = recent.where((e) =>
        e.mood == MoodType.stressed || e.mood == MoodType.sad).length;
    final isStruggling = recentNegative >= 3 || recentStressed >= 3;

    // Determine trend category
    final trendCategory = _determineTrendCategory(
      positiveCount, negativeCount, dominantMood, isStruggling,
    );

    // Generate messages and recommendations
    final insightMessage = _generateInsight(
      trendCategory, dominantMood, entries.length,
    );
    final adaptiveMessage = _generateAdaptiveMessage(
      trendCategory, isStruggling, dominantMood,
    );
    final recommendations = _generateRecommendations(
      trendCategory, isStruggling, dominantMood,
    );

    return MoodTrend(
      dominantMood: dominantMood,
      trendCategory: trendCategory,
      insightMessage: insightMessage,
      adaptiveMessage: adaptiveMessage,
      recommendations: recommendations,
      isStruggling: isStruggling,
      totalEntries: entries.length,
    );
  }

  /// Async variant for future AI provider compatibility.
  Future<MoodTrend> analyzeAsync(List<MoodEntry> entries) async {
    return analyze(entries);
  }

  /// Generate a single adaptive insight string for the insights page.
  String getAdaptiveInsight(List<MoodEntry> entries) {
    return analyze(entries).insightMessage;
  }

  /// Generate smart, history-prioritized recommendations.
  List<String> getSmartRecommendations(List<MoodEntry> entries) {
    return analyze(entries).recommendations;
  }

  /// Generate dynamic observations for the Mood Journey section.
  List<String> getMoodJourneyObservations(List<MoodEntry> entries) {
    if (entries.length < 3) {
      return ["Keep logging your moods to unlock your personalized mood journey."];
    }
    
    final observations = <String>[];
    
    // 1. Analyze positivity trend
    int positiveCount = entries.where((e) => _positiveSet.contains(e.mood)).length;
    double positiveRatio = positiveCount / entries.length;
    if (positiveRatio > 0.6) {
      observations.add("You've been experiencing a predominantly positive trend recently.");
    } else if (positiveRatio < 0.3) {
      observations.add("Your mood has been on the lower side. Consider taking some time for self-care.");
    }
    
    // 2. Check for specific mood improvements or spikes
    final stressedCount = entries.where((e) => e.mood == MoodType.stressed).length;
    if (stressedCount > 2) {
      observations.add("Stress levels have been noticeable. Mindfulness might help ground you.");
    }
    
    final happyCount = entries.where((e) => e.mood == MoodType.happy).length;
    if (happyCount >= 3) {
      observations.add("You've recorded multiple moments of happiness! Keep doing what you love.");
    }
    
    if (observations.isEmpty) {
      observations.add("Your emotional state has been balanced and steady.");
    }
    
    return observations;
  }

  // ── Private Helpers ──

  String _determineTrendCategory(
    int positive, int negative, MoodType dominant, bool isStruggling,
  ) {
    if (isStruggling) {
      if (dominant == MoodType.stressed) return 'stressed';
      return 'negative';
    }
    if (positive > negative * 2) return 'positive';
    if (negative > positive * 2) return 'negative';
    return 'mixed';
  }

  String _generateInsight(String category, MoodType dominant, int total) {
    if (total < 3) {
      return 'Keep logging moods to unlock deeper insights.';
    }

    return switch (category) {
      'positive' => switch (dominant) {
        MoodType.happy => "You've had a positive week. Keep building on these moments!",
        MoodType.motivated => "Your consistency is impressive. Keep your momentum going!",
        MoodType.relaxed => "You've found a peaceful rhythm. Protect this balance.",
        _ => "You've had a great week overall. Keep it up!",
      },
      'negative' => switch (dominant) {
        MoodType.sad => "This has been a reflective period. Be gentle with yourself.",
        MoodType.angry => "There's been some turbulence lately. Channel it constructively.",
        _ => "This week has had its challenges. You're handling them.",
      },
      'stressed' => "This week has been demanding. Consider taking more breaks and breathing exercises.",
      'mixed' => "Your emotional range shows great self-awareness. Keep checking in with yourself.",
      _ => "Keep logging to discover your patterns.",
    };
  }

  String _generateAdaptiveMessage(
    String category, bool isStruggling, MoodType dominant,
  ) {
    if (isStruggling) {
      return switch (dominant) {
        MoodType.stressed =>
          "You've been carrying a lot over the last few days. Taking a small break today could really help.",
        MoodType.sad =>
          "It's been a tough stretch. Remember, it's okay to lean on others right now.",
        MoodType.angry =>
          "There's been a lot of intensity lately. A breathing exercise might release some of that pressure.",
        _ =>
          "Things have been heavy recently. Be kind to yourself today.",
      };
    }

    return switch (category) {
      'positive' =>
        "You've maintained a positive mindset this week. Keep building this momentum!",
      'mixed' =>
        "You're navigating life's ups and downs with awareness. That's a strength.",
      _ => '',
    };
  }

  List<String> _generateRecommendations(
    String category, bool isStruggling, MoodType dominant,
  ) {
    if (isStruggling) {
      // Prioritize calming activities for struggling users
      return switch (dominant) {
        MoodType.stressed => ['breathing', 'relaxation_music', 'journaling', 'walk'],
        MoodType.sad => ['breathing', 'comfort_music', 'journaling', 'talk_to_friend'],
        MoodType.angry => ['breathing', 'exercise', 'journaling', 'cold_water'],
        _ => ['breathing', 'journaling', 'music', 'rest'],
      };
    }

    return switch (category) {
      'positive' => ['goals', 'focus_music', 'achievements', 'share_joy'],
      'mixed' => ['journaling', 'music', 'breathing', 'reflection'],
      'negative' => ['breathing', 'music', 'journaling', 'rest'],
      _ => ['journaling', 'music', 'breathing'],
    };
  }
}
