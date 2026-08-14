import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../models/mood_theme_model.dart';
import '../core/theme/mood_theme_repository.dart';
import '../services/mood_theme_service.dart';
import '../services/greeting_service.dart';

/// Manages the active mood theme state.
///
/// Improvement #3: This provider manages STATE ONLY. Business logic
/// (trend analysis, greeting generation) is delegated to services.
///
/// Responsibilities:
/// - Hold the active mood and its resolved theme config
/// - Persist mood preference via [MoodThemeService]
/// - Provide greeting via [GreetingService]
class MoodThemeProvider extends ChangeNotifier {
  final MoodThemeRepository _repository = MoodThemeRepository.instance;
  final MoodThemeService _persistenceService = MoodThemeService();
  final GreetingService _greetingService = GreetingService();

  MoodType? _activeMood;
  MoodThemeConfig _currentConfig = MoodThemeConfig.neutral;

  MoodThemeProvider() {
    _restoreFromStorage();
  }

  String? _userId;

  // ── Getters ──

  /// The currently active mood, or null if none selected.
  MoodType? get activeMood => _activeMood;

  /// The resolved theme configuration for the active mood.
  /// Returns the neutral config if no mood is selected.
  MoodThemeConfig get currentConfig => _currentConfig;

  /// Whether a mood is currently active.
  bool get hasMood => _activeMood != null;

  /// Get a contextual greeting based on time + active mood.
  GreetingResult get greeting => _greetingService.getGreeting(_activeMood);

  // ── Actions ──

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    
    if (userId == null) {
      clearMood();
    } else {
      _restoreFromStorage();
    }
  }

  /// Set the active mood theme.
  ///
  /// Updates state, persists to Hive locally, and syncs to Firestore
  /// in the background (fire-and-forget).
  Future<void> setMood(MoodType mood, {String? userId}) async {
    _activeMood = mood;
    _currentConfig = _repository.getConfig(mood);
    notifyListeners();

    final actualUserId = _userId ?? userId;

    if (actualUserId != null) {
      // Persist locally (Hive)
      await _persistenceService.saveMoodPreference(actualUserId, mood);
      // Sync to Firestore in background
      _persistenceService.syncToFirestore(actualUserId, mood);
    }
  }

  /// Clear the active mood, reverting to the default theme.
  void clearMood() {
    _activeMood = null;
    _currentConfig = MoodThemeConfig.neutral;
    Future.microtask(() => notifyListeners());
  }

  // ── Private ──

  /// Restore the last selected mood from Hive on startup.
  void _restoreFromStorage() {
    if (_userId == null) return;
    
    final savedMood = _persistenceService.loadMoodPreference(_userId!);
    if (savedMood != null) {
      _activeMood = savedMood;
      _currentConfig = _repository.getConfig(savedMood);
      Future.microtask(() => notifyListeners());
    }
  }
}
