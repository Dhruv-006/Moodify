import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_model.dart';
import '../core/constants/app_constants.dart';

/// Handles persistence of the user's active mood preference.
///
/// Dual storage strategy:
/// - **Hive** (local): Instant read on app launch, no network required.
/// - **Firestore**: Synced for cross-device consistency.
class MoodThemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Hive (Local) ──

  /// Save the selected mood to local Hive storage.
  Future<void> saveMoodPreference(String userId, MoodType mood) async {
    try {
      final box = Hive.box(AppConstants.moodPrefsBox);
      await box.put('${userId}_${AppConstants.lastMoodKey}', mood.name);
    } catch (e) {
      // Silently fail — local persistence is best-effort
    }
  }

  /// Read the last mood from Hive. Returns null if not set.
  /// Synchronous after Hive is initialized.
  MoodType? loadMoodPreference(String userId) {
    try {
      final box = Hive.box(AppConstants.moodPrefsBox);
      final moodName = box.get('${userId}_${AppConstants.lastMoodKey}') as String?;
      if (moodName == null) return null;
      return MoodType.values.where((e) => e.name == moodName).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // ── Firestore (Remote) ──

  /// Sync the selected mood to the user's Firestore profile.
  /// Fire-and-forget — errors are handled silently.
  Future<void> syncToFirestore(String userId, MoodType mood) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'lastMood': mood.name,
        'lastMoodTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail — Firestore sync is best-effort
    }
  }

  /// Load the last mood from the user's Firestore profile.
  Future<MoodType?> loadFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final moodName = doc.data()?['lastMood'] as String?;
      if (moodName == null) return null;
      return MoodType.values.where((e) => e.name == moodName).firstOrNull;
    } catch (e) {
      return null;
    }
  }
}
