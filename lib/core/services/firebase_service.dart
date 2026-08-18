import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/mood_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for a user's mood entries
  CollectionReference<Map<String, dynamic>> _moodsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('moods');
  }

  /// Add a new mood entry to Firestore
  Future<String> addMoodEntry(String userId, MoodEntry entry) async {
    final doc = await _moodsCollection(userId).add(entry.toMap());
    return doc.id;
  }

  /// Get all mood entries for a user, sorted by date descending
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final snapshot = await _moodsCollection(
      userId,
    ).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => MoodEntry.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Stream of mood entries for real-time updates
  Stream<List<MoodEntry>> moodEntriesStream(String userId) {
    return _moodsCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MoodEntry.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Update a specific mood entry
  Future<void> updateMoodEntry(
    String userId,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    await _moodsCollection(userId).doc(entryId).update(data);
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(String userId, String entryId) async {
    await _moodsCollection(userId).doc(entryId).delete();
  }

  /// Create or update the user profile document
  Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  /// Delete all data for a guest user securely
  Future<void> deleteGuestData(String userId) async {
    // Force a server-side get to ensure we are actually online and have the complete list
    final snapshot = await _moodsCollection(userId).get(const GetOptions(source: Source.server));
    
    final batch = _firestore.batch();
    
    // Delete all mood documents
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the root user profile document
    batch.delete(_firestore.collection('users').doc(userId));
    
    // Commit the batch
    await batch.commit();
  }
}
