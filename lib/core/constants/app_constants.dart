class AppConstants {
  static const String appName = 'Moodify';
  static const String themePrefsKey = 'theme_mode';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String moodsCollection = 'moods';

  // Hive storage for mood persistence
  static const String moodPrefsBox = 'moodify_prefs';
  static const String lastMoodKey = 'last_mood';
}
