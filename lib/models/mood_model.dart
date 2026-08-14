import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType {
  happy,
  sad,
  angry,
  stressed,
  relaxed,
  motivated,
}

class MoodEntry {
  final String? id; // Firestore document ID
  final String moodType;
  final DateTime date;
  final String? note;
  final List<String> activities;

  MoodEntry({
    this.id,
    required this.moodType,
    required this.date,
    this.note,
    this.activities = const [],
  });

  MoodType get mood => MoodType.values.firstWhere(
        (e) => e.name == moodType,
        orElse: () => MoodType.happy,
      );

  /// Convert to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'moodType': moodType,
      'date': Timestamp.fromDate(date),
      'note': note,
      'activities': activities,
    };
  }

  /// Create a MoodEntry from a Firestore document
  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      id: id,
      moodType: map['moodType'] as String? ?? 'happy',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'] as String?,
      activities: List<String>.from(map['activities'] ?? []),
    );
  }

  /// Create a copy with updated fields
  MoodEntry copyWith({
    String? id,
    String? moodType,
    DateTime? date,
    String? note,
    List<String>? activities,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      moodType: moodType ?? this.moodType,
      date: date ?? this.date,
      note: note ?? this.note,
      activities: activities ?? this.activities,
    );
  }
}

class MoodData {
  final MoodType type;
  final String name;
  final String description;
  final String subtitle;
  final String emoji;
  final String heroTitle;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final Color darkColor;
  final List<String> quotes;
  final List<String> quoteAuthors;
  final List<String> activities;
  final List<String> activityDescriptions;
  final List<IconData> activityIcons;
  final List<Map<String, String>> musicSuggestions;
  final String journalPrompt;
  final String journalSectionTitle;
  final String activitiesSectionTitle;
  final String quotesSectionTitle;
  final String musicSectionTitle;
  final String message;
  final String ctaLabel;
  final bool showBreathingCTA;

  const MoodData({
    required this.type,
    required this.name,
    required this.description,
    required this.subtitle,
    required this.emoji,
    required this.heroTitle,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.darkColor,
    required this.quotes,
    required this.quoteAuthors,
    required this.activities,
    this.activityDescriptions = const [],
    this.activityIcons = const [],
    required this.musicSuggestions,
    required this.journalPrompt,
    this.journalSectionTitle = 'Journal',
    this.activitiesSectionTitle = 'Recommended Activities',
    this.quotesSectionTitle = 'Quotes for You',
    this.musicSectionTitle = 'Music Suggestions',
    required this.message,
    this.ctaLabel = 'Log This Mood',
    this.showBreathingCTA = false,
  });

  static List<MoodData> allMoods = [
    // ── Happy (from Happy.html) ──
    MoodData(
      type: MoodType.happy,
      name: 'Happy',
      description: 'User is feeling positive and energetic',
      subtitle: "That's great. Keep the energy alive.",
      heroTitle: "You're Feeling Happy",
      emoji: '😊',
      icon: Icons.sentiment_very_satisfied,
      color: const Color(0xFFFBC02D),
      lightColor: const Color(0xFFFEF08A),
      darkColor: const Color(0xFFF9A825),
      message: "That's wonderful! Keep spreading the positive energy!",
      activitiesSectionTitle: 'Keep it flowing',
      activities: [
        'Share your joy',
        'Do something kind',
        'Dance to your favorite song',
      ],
      activityDescriptions: [
        '',
        '',
        'Let loose and enjoy the moment',
      ],
      activityIcons: [
        Icons.favorite_rounded,
        Icons.volunteer_activism_rounded,
        Icons.music_note_rounded,
      ],
      quotesSectionTitle: 'Uplifting Thoughts',
      quotes: [
        'Happiness is not something ready made. It comes from your own actions.',
        'For every minute you are angry you lose sixty seconds of happiness.',
      ],
      quoteAuthors: ['Dalai Lama', 'Ralph Waldo Emerson'],
      musicSuggestions: [
        {'title': 'Happy', 'artist': 'Pharrell Williams'},
        {'title': 'Walking on Sunshine', 'artist': 'Katrina & The Waves'},
        {'title': 'Good Vibrations', 'artist': 'The Beach Boys'},
      ],
      journalSectionTitle: 'Capture the Feeling',
      journalPrompt: 'What made today feel good?',
      ctaLabel: 'Save Note',
    ),

    // ── Sad (from Sad.html) ──
    MoodData(
      type: MoodType.sad,
      name: 'Sad',
      description: 'User feels low or emotionally down',
      subtitle: 'Allow yourself to feel. This moment will pass.',
      heroTitle: "It's Okay to Feel Sad",
      emoji: '😢',
      icon: Icons.sentiment_dissatisfied,
      color: const Color(0xFF0288D1),
      lightColor: const Color(0xFFD3E3FF),
      darkColor: const Color(0xFF01579B),
      message: "It's okay to feel sad. Allow yourself to feel, and remember, this too shall pass.",
      activitiesSectionTitle: 'Comforting Activities',
      activities: [
        'Listen to Music',
        'Talk to a Friend',
        'Cozy Up',
      ],
      activityIcons: [
        Icons.headphones_rounded,
        Icons.forum_rounded,
        Icons.bed_rounded,
      ],
      quotesSectionTitle: 'Gentle Quotes',
      quotes: [
        'Tears come from the heart and not from the brain.',
      ],
      quoteAuthors: ['Leonardo da Vinci'],
      musicSectionTitle: 'Soothing Music',
      musicSuggestions: [
        {'title': 'Rain on Windowpane', 'artist': 'Nature Sounds • 4:30'},
        {'title': 'Gentle Piano Waves', 'artist': 'Acoustic • 5:15'},
        {'title': 'Deep Ambient Calm', 'artist': 'Electronic • 8:00'},
      ],
      journalSectionTitle: 'Journal Prompt',
      journalPrompt: "What's weighing on your heart?",
      ctaLabel: 'Start Gentle Breathing',
      showBreathingCTA: true,
    ),

    // ── Angry (from Angry.html) ──
    MoodData(
      type: MoodType.angry,
      name: 'Angry',
      description: 'User feels irritated or frustrated',
      subtitle: 'Take a deep breath. Let the intensity settle.',
      heroTitle: 'Releasing the Heat',
      emoji: '😠',
      icon: Icons.sentiment_very_dissatisfied,
      color: const Color(0xFFD32F2F),
      lightColor: const Color(0xFFFFEBEE),
      darkColor: const Color(0xFFB71C1C),
      message: "Take a step back and breathe. Your feelings are valid, but let's channel them positively.",
      activitiesSectionTitle: 'Release Activities',
      activities: [
        'Physical Exercise',
        'Scream into a Pillow',
        'Cold Water Splash',
      ],
      activityDescriptions: [
        'Channel energy into a quick, intense workout.',
        'A safe way to physically release pent-up vocal tension.',
        'Shock your system gently to reset your nervous response.',
      ],
      activityIcons: [
        Icons.fitness_center_rounded,
        Icons.record_voice_over_rounded,
        Icons.water_drop_rounded,
      ],
      quotesSectionTitle: 'Perspective',
      quotes: [
        'Holding onto anger is like grasping a hot coal with the intent of throwing it at someone else; you are the one who gets burned.',
      ],
      quoteAuthors: ['Buddha'],
      musicSectionTitle: 'High-Energy Venting',
      musicSuggestions: [
        {'title': 'Killing In The Name', 'artist': 'Rage Against The Machine'},
        {'title': 'Duality', 'artist': 'Slipknot'},
      ],
      journalSectionTitle: 'What triggered this feeling?',
      journalPrompt: 'What triggered this feeling?',
      ctaLabel: 'Start Box Breathing',
      showBreathingCTA: true,
    ),

    // ── Stressed (from Stressed.html) ──
    MoodData(
      type: MoodType.stressed,
      name: 'Stressed',
      description: 'User feels pressure or anxiety',
      subtitle: 'Take a pause. You do not need to solve everything right now.',
      heroTitle: "You're Feeling Stressed",
      emoji: '😣',
      icon: Icons.sick,
      color: const Color(0xFFF57C00),
      lightColor: const Color(0xFFFFF3E0),
      darkColor: const Color(0xFFE65100),
      message: "You seem stressed today. Slow down and take a short break. You've got this.",
      activitiesSectionTitle: 'Recommended Activities',
      activities: [
        'Take a 5-minute walk',
        'Drink water',
        'Write what is bothering you',
        'Do a breathing exercise',
      ],
      activityIcons: [
        Icons.directions_walk_rounded,
        Icons.water_drop_rounded,
        Icons.edit_note_rounded,
        Icons.air_rounded,
      ],
      quotesSectionTitle: 'Gentle Reminders',
      quotes: [
        'Breath is the bridge which connects life to consciousness, which unites your body to your thoughts.',
        "You don't have to control your thoughts. You just have to stop letting them control you.",
        'Almost everything will work again if you unplug it for a few minutes, including you.',
      ],
      quoteAuthors: ['Thích Nhất Hạnh', 'Dan Millman', 'Anne Lamott'],
      musicSectionTitle: 'Calming Sounds',
      musicSuggestions: [
        {'title': 'Weightless', 'artist': 'Marconi Union'},
        {'title': 'River Flows In You', 'artist': 'Yiruma'},
        {'title': 'Rain Sounds', 'artist': 'Nature Ambience'},
      ],
      journalSectionTitle: 'Release Your Thoughts',
      journalPrompt: 'What is making you feel stressed today?',
      ctaLabel: 'Start Breathing Exercise',
      showBreathingCTA: true,
    ),

    // ── Relaxed (from Relaxed.html) ──
    MoodData(
      type: MoodType.relaxed,
      name: 'Relaxed',
      description: 'User feels peaceful and calm',
      subtitle: 'Savor this stillness. You are exactly where you need to be right now.',
      heroTitle: 'Peaceful & Present',
      emoji: '😌',
      icon: Icons.self_improvement,
      color: const Color(0xFF388E3C),
      lightColor: const Color(0xFFCAFECD),
      darkColor: const Color(0xFF1B5E20),
      message: "You're in a great state of mind. Enjoy this peaceful moment and let it recharge you.",
      activitiesSectionTitle: 'Mindfulness Activities',
      activities: [
        'Guided Meditation',
        'Nature Walk',
        'Light Stretching',
      ],
      activityDescriptions: [
        '10 min • Breath focus',
        '20 min • Observation',
        '5 min • Body scan',
      ],
      activityIcons: [
        Icons.self_improvement_rounded,
        Icons.park_rounded,
        Icons.accessibility_new_rounded,
      ],
      quotesSectionTitle: 'Zen Quote',
      quotes: [
        'Smile, breathe and go slowly.',
      ],
      quoteAuthors: ['Thich Nhat Hanh'],
      musicSectionTitle: 'Ambient Soundscapes',
      musicSuggestions: [
        {'title': 'Forest Rain', 'artist': '45 min'},
        {'title': 'Ocean Tides', 'artist': '60 min'},
        {'title': 'Soft Crackle', 'artist': '30 min'},
      ],
      journalSectionTitle: 'Reflection',
      journalPrompt: 'What brings you peace right now?',
      ctaLabel: 'Start Deep Meditation',
    ),

    // ── Motivated (from Motivated.html) ──
    MoodData(
      type: MoodType.motivated,
      name: 'Motivated',
      description: 'User wants productivity and growth',
      subtitle: "You've got the spark. Let's channel this energy.",
      heroTitle: 'Fueling the Fire',
      emoji: '🚀',
      icon: Icons.rocket_launch,
      color: const Color(0xFF624AC3),
      lightColor: const Color(0xFFC5B8FF),
      darkColor: const Color(0xFF3F209E),
      message: "You're on fire! Channel this energy into something amazing today!",
      activitiesSectionTitle: 'Action Activities',
      activities: [
        'Set 3 Goals',
        'Clear Your Desk',
        'Start the Hardest Task',
      ],
      activityDescriptions: [
        'Break down your ambition into actionable steps.',
        'A clear space fosters a clear, focused mind.',
        'Tackle the frog first while your energy is peaking.',
      ],
      activityIcons: [
        Icons.checklist_rounded,
        Icons.cleaning_services_rounded,
        Icons.bolt_rounded,
      ],
      quotesSectionTitle: 'Empowering Quote',
      quotes: [
        'The secret of getting ahead is getting started.',
      ],
      quoteAuthors: ['Mark Twain'],
      musicSectionTitle: 'Upbeat Focus Music',
      musicSuggestions: [
        {'title': 'Deep Focus Beats', 'artist': 'Lofi & Chillhop • 45 min'},
        {'title': 'High Energy Synthesis', 'artist': 'Electronic • 60 min'},
        {'title': 'Acoustic Drive', 'artist': 'Upbeat Instrumental • 30 min'},
      ],
      journalSectionTitle: 'Journal Prompt',
      journalPrompt: 'What do you want to achieve today?',
      ctaLabel: 'Plan Your Next Move',
    ),
  ];

  static MoodData getMoodData(MoodType type) {
    return allMoods.firstWhere((m) => m.type == type);
  }
}
