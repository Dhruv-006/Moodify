import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/mood_model.dart';

class _CacheEntry<T> {
  final int version;
  final T data;
  _CacheEntry(this.version, this.data);
}

class MoodProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  StreamSubscription? _subscription;

  int _dataVersion = 0;
  final Map<String, _CacheEntry> _analyticsCache = {};

  T _memoize<T>(String key, T Function() compute) {
    final entry = _analyticsCache[key];
    if (entry != null && entry.version == _dataVersion) {
      return entry.data as T;
    }
    final result = compute();
    _analyticsCache[key] = _CacheEntry<T>(_dataVersion, result);
    return result;
  }

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      Future.microtask(() => notifyListeners());
    }
  }

  /// Set the current user and load their mood entries
  void setUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();

    if (userId == null) {
      _entries = [];
      _dataVersion++;
      Future.microtask(() => notifyListeners());
      return;
    }

    _listenToEntries(userId);
  }

  void _listenToEntries(String userId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    // Set up the real-time listener for initial data and future updates
    _subscription?.cancel();
    _subscription = _firebaseService
        .moodEntriesStream(userId)
        .listen(
          (entries) {
            _entries = entries;
            _dataVersion++;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('MoodProvider stream error: $error');
            if (error.toString().contains('permission-denied')) {
              Future.delayed(const Duration(seconds: 2), () {
                if (_userId == userId) _listenToEntries(userId);
              });
            } else {
              _isLoading = false;
              notifyListeners();
            }
          },
        );
  }

  /// Load entries once (fallback, used if stream isn't needed)
  Future<void> loadEntries() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _firebaseService.getMoodEntries(_userId!);
      _dataVersion++;
    } catch (e) {
      _errorMessage = 'Failed to load entries.';
      debugPrint('Load entries error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(MoodType moodType, {String? note}) async {
    if (_userId == null) return;

    final moodData = MoodData.getMoodData(moodType);
    final entry = MoodEntry(
      moodType: moodType.name,
      date: DateTime.now(),
      note: note,
      activities: moodData.activities,
    );

    // 1. Store previous state
    final previousEntries = List<MoodEntry>.from(_entries);
    
    // 2. Optimistic update
    final optimisticEntry = entry.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}');
    _entries.insert(0, optimisticEntry);
    _dataVersion++;
    notifyListeners();

    try {
      // 3. Firestore mutation
      final id = await _firebaseService.addMoodEntry(_userId!, entry);
      
      // 4. Update the temporary ID with the real one
      final index = _entries.indexWhere((e) => e.id == optimisticEntry.id);
      if (index >= 0) {
        _entries[index] = entry.copyWith(id: id);
        _dataVersion++;
        notifyListeners();
      }
    } catch (e) {
      // 5. Rollback on failure
      debugPrint('Add entry failed: $e');
      _entries = previousEntries;
      _dataVersion++;
      _errorMessage = 'Failed to save mood. Please check your connection.';
      notifyListeners();
    }
  }

  Future<void> updateNote(int index, String note) async {
    if (_userId == null || index < 0 || index >= _entries.length) return;

    final entry = _entries[index];
    if (entry.id == null) return;

    // 1. Store previous state
    final previousEntries = List<MoodEntry>.from(_entries);

    // 2. Optimistic update
    _entries[index] = entry.copyWith(note: note);
    _dataVersion++;
    notifyListeners();

    try {
      // 3. Firestore mutation
      await _firebaseService.updateMoodEntry(_userId!, entry.id!, {
        'note': note,
      });
    } catch (e) {
      // 4. Rollback on failure
      debugPrint('Update note failed: $e');
      _entries = previousEntries;
      _dataVersion++;
      _errorMessage = 'Failed to update note. Please try again.';
      notifyListeners();
    }
  }

  /// Update note by entry ID (used by auto-save)
  Future<void> updateNoteById(String entryId, String note) async {
    if (_userId == null) return;

    final index = _entries.indexWhere((e) => e.id == entryId);
    final existsLocally = index >= 0;

    List<MoodEntry>? previousEntries;

    if (existsLocally) {
      // 1. Store previous state
      previousEntries = List<MoodEntry>.from(_entries);

      // 2. Optimistic update
      _entries[index] = _entries[index].copyWith(note: note);
      _dataVersion++;
      notifyListeners();
    }

    try {
      // 3. Firestore mutation
      await _firebaseService.updateMoodEntry(_userId!, entryId, {'note': note});
    } catch (e) {
      // 4. Rollback on failure
      debugPrint('Auto-save note failed: $e');
      if (existsLocally && previousEntries != null) {
        _entries = previousEntries;
        _dataVersion++;
      }
      _errorMessage = 'Auto-save failed. Check connection.';
      notifyListeners();
    }
  }

  /// Delete a mood entry by ID
  Future<void> deleteEntry(String entryId) async {
    if (_userId == null) return;

    final index = _entries.indexWhere((e) => e.id == entryId);
    final existsLocally = index >= 0;

    List<MoodEntry>? previousEntries;

    if (existsLocally) {
      // 1. Store previous state
      previousEntries = List<MoodEntry>.from(_entries);

      // 2. Optimistic removal
      _entries.removeAt(index);
      _dataVersion++;
      notifyListeners();
    }

    try {
      // 3. Firestore mutation
      await _firebaseService.deleteMoodEntry(_userId!, entryId);
    } catch (e) {
      // 4. Rollback on failure
      debugPrint('Delete entry failed: $e');
      if (existsLocally && previousEntries != null) {
        _entries = previousEntries;
        _dataVersion++;
      }
      _errorMessage = 'Failed to delete mood. Please try again.';
      notifyListeners();
    }
  }

  List<MoodEntry> getEntriesForToday() {
    final now = DateTime.now();
    return _entries
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .toList();
  }

  List<MoodEntry> getEntriesForWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries.where((e) => e.date.isAfter(weekAgo)).toList();
  }

  List<MoodEntry> getEntriesForMonth() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return _entries.where((e) => e.date.isAfter(monthAgo)).toList();
  }

  MoodType? getMostFrequentMood() {
    return _memoize('mostFrequentMood', () {
      if (_entries.isEmpty) return null;
      final weekEntries = getEntriesForWeek();
      if (weekEntries.isEmpty) return _entries.first.mood;

      final counts = <String, int>{};
      for (final entry in weekEntries) {
        counts[entry.moodType] = (counts[entry.moodType] ?? 0) + 1;
      }

      final maxEntry = counts.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      return MoodType.values.firstWhere((e) => e.name == maxEntry.key);
    });
  }

  int getMoodCount(MoodType type) {
    return _memoize('moodCount_${type.name}', () {
      return getEntriesForWeek().where((e) => e.mood == type).length;
    });
  }

  int getStreak() {
    return _memoize('streak', () {
      if (_entries.isEmpty) return 0;

      int streak = 0;
      DateTime currentDate = DateTime.now();

      for (int i = 0; i < 365; i++) {
        final checkDate = currentDate.subtract(Duration(days: i));
        final hasEntry = _entries.any(
          (e) =>
              e.date.year == checkDate.year &&
              e.date.month == checkDate.month &&
              e.date.day == checkDate.day,
        );

        if (hasEntry) {
          streak++;
        } else if (i > 0) {
          break;
        }
      }
      return streak;
    });
  }

  Map<String, int> getWeeklyMoodCounts() {
    final weekEntries = getEntriesForWeek();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = <String, int>{};
    for (final day in days) {
      counts[day] = 0;
    }

    for (final entry in weekEntries) {
      final dayIndex = entry.date.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) {
        counts[days[dayIndex]] = (counts[days[dayIndex]] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<MoodType, int> getMoodDistribution() {
    final weekEntries = getEntriesForWeek();
    final dist = <MoodType, int>{};
    for (final type in MoodType.values) {
      final count = weekEntries.where((e) => e.mood == type).length;
      if (count > 0) dist[type] = count;
    }
    return dist;
  }

  // ── Filter-based analytics ──

  /// Get entries for the previous calendar month
  List<MoodEntry> getEntriesForLastMonth() {
    final now = DateTime.now();
    final firstOfThisMonth = DateTime(now.year, now.month, 1);
    final firstOfLastMonth = DateTime(now.year, now.month - 1, 1);
    return _entries
        .where(
          (e) =>
              e.date.isAfter(
                firstOfLastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              e.date.isBefore(firstOfThisMonth),
        )
        .toList();
  }

  /// Get entries for a named filter
  List<MoodEntry> getEntriesForFilter(String filter) {
    switch (filter) {
      case 'This Week':
        return getEntriesForWeek();
      case 'This Month':
        return getEntriesForMonth();
      case 'Last Month':
        return getEntriesForLastMonth();
      case 'All Time':
        return List.from(_entries);
      default:
        return getEntriesForWeek();
    }
  }

  /// Parameterized mood distribution
  Map<MoodType, int> getMoodDistributionForFilter(String filter) {
    return _memoize('dist_$filter', () {
      final entries = getEntriesForFilter(filter);
      final dist = <MoodType, int>{};
      for (final type in MoodType.values) {
        final count = entries.where((e) => e.mood == type).length;
        if (count > 0) dist[type] = count;
      }
      return dist;
    });
  }

  /// Parameterized weekly mood counts by mood type
  Map<String, Map<MoodType, int>> getWeeklyMoodCountsForFilter(String filter) {
    return _memoize('weeklyCounts_$filter', () {
      final entries = getEntriesForFilter(filter);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final counts = <String, Map<MoodType, int>>{};
      for (final day in days) {
        counts[day] = {};
      }
      for (final entry in entries) {
        final dayIndex = entry.date.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          final dayStr = days[dayIndex];
          counts[dayStr]![entry.mood] = (counts[dayStr]![entry.mood] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  /// Parameterized most frequent mood
  MoodType? getMostFrequentMoodForFilter(String filter) {
    return _memoize('freqMood_$filter', () {
      final entries = getEntriesForFilter(filter);
      if (entries.isEmpty) return null;
      final counts = <String, int>{};
      for (final entry in entries) {
        counts[entry.moodType] = (counts[entry.moodType] ?? 0) + 1;
      }
      final maxEntry = counts.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      return MoodType.values.firstWhere((e) => e.name == maxEntry.key);
    });
  }

  /// Parameterized mood count for a specific type
  int getMoodCountFor(MoodType type, List<MoodEntry> entries) {
    return entries.where((e) => e.mood == type).length;
  }

  /// Longest consecutive-day streak within given entries
  int getStreakForFilter(String filter) {
    return _memoize('streak_$filter', () {
      final entries = getEntriesForFilter(filter);
      if (entries.isEmpty) return 0;

      final uniqueDays = <DateTime>{};
      for (final e in entries) {
        uniqueDays.add(DateTime(e.date.year, e.date.month, e.date.day));
      }
      final sorted = uniqueDays.toList()..sort();

      int maxStreak = 1;
      int current = 1;
      for (int i = 1; i < sorted.length; i++) {
        if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
          current++;
          if (current > maxStreak) maxStreak = current;
        } else {
          current = 1;
        }
      }
      return maxStreak;
    });
  }

  /// Positive (happy, relaxed, motivated) vs Negative (sad, angry, stressed) ratio
  Map<String, int> getPositiveNegativeRatio(List<MoodEntry> entries) {
    const positive = {MoodType.happy, MoodType.relaxed, MoodType.motivated};
    int pos = 0, neg = 0;
    for (final e in entries) {
      if (positive.contains(e.mood)) {
        pos++;
      } else {
        neg++;
      }
    }
    return {'positive': pos, 'negative': neg};
  }

  /// Average moods per day
  double getAverageMoodsPerDay(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final uniqueDays = <String>{};
    for (final e in entries) {
      uniqueDays.add('${e.date.year}-${e.date.month}-${e.date.day}');
    }
    return entries.length / uniqueDays.length;
  }

  /// Monthly bar data: entries grouped by day-of-month and mood type
  Map<int, Map<MoodType, int>> getMonthlyBarDataForFilter(String filter) {
    return _memoize('monthlyBar_$filter', () {
      final entries = getEntriesForFilter(filter);
      final data = <int, Map<MoodType, int>>{};
      
      // Determine the month and year from the first entry, or fallback to current month
      DateTime date = DateTime.now();
      if (entries.isNotEmpty) {
        date = entries.first.date;
      }
      
      final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        data[i] = {};
      }
      
      for (final e in entries) {
        final day = e.date.day;
        if (data.containsKey(day)) {
          data[day]![e.mood] = (data[day]![e.mood] ?? 0) + 1;
        }
      }
      return data;
    });
  }

  /// Weekly comparison: entries split into weeks within a month
  List<Map<String, int>> getWeeklyComparisonData(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];

    // Group entries into up to 5 weeks
    final weeks = <Map<String, int>>[];
    for (int w = 0; w < 5; w++) {
      weeks.add(<String, int>{});
    }

    for (final e in entries) {
      final weekIndex = ((e.date.day - 1) / 7).floor().clamp(0, 4);
      final moodName = e.moodType;
      weeks[weekIndex][moodName] = (weeks[weekIndex][moodName] ?? 0) + 1;
    }

    return weeks.where((w) => w.isNotEmpty).toList();
  }

  MoodEntry? get lastEntry => _entries.isNotEmpty ? _entries.first : null;

  /// Helper to get a score for a mood to calculate best/worst days
  int _getMoodScore(MoodType type) {
    switch (type) {
      case MoodType.happy: return 5;
      case MoodType.motivated: return 4;
      case MoodType.relaxed: return 3;
      case MoodType.stressed: return 2;
      case MoodType.sad: return 1;
      case MoodType.angry: return 0;
    }
  }

  /// Get the "Best Day" based on average mood score
  DateTime? getBestDayForFilter(String filter) {
    return _memoize('bestDay_$filter', () {
      final entries = getEntriesForFilter(filter);
      if (entries.isEmpty) return null;
      final map = _getEntriesByDate(entries);
      DateTime? bestDay;
      double highestScore = -1;
      for (final entry in map.entries) {
        final avg = entry.value.map((e) => _getMoodScore(e.mood)).reduce((a, b) => a + b) / entry.value.length;
        if (avg > highestScore) {
          highestScore = avg;
          bestDay = entry.key;
        }
      }
      return bestDay;
    });
  }

  /// Get the "Worst Day" based on average mood score
  DateTime? getWorstDayForFilter(String filter) {
    return _memoize('worstDay_$filter', () {
      final entries = getEntriesForFilter(filter);
      if (entries.isEmpty) return null;
      final map = _getEntriesByDate(entries);
      DateTime? worstDay;
      double lowestScore = 999;
      for (final entry in map.entries) {
        final avg = entry.value.map((e) => _getMoodScore(e.mood)).reduce((a, b) => a + b) / entry.value.length;
        if (avg < lowestScore) {
          lowestScore = avg;
          worstDay = entry.key;
        }
      }
      return worstDay;
    });
  }

  /// Group entries by Date (ignoring time)
  Map<DateTime, List<MoodEntry>> _getEntriesByDate(List<MoodEntry> entries) {
    final map = <DateTime, List<MoodEntry>>{};
    for (final e in entries) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(date, () => []).add(e);
    }
    return map;
  }

  /// Public accessor for entries by date
  Map<DateTime, List<MoodEntry>> getEntriesByDate(List<MoodEntry> entries) {
    return _getEntriesByDate(entries);
  }

  /// Calculates a consistency score (0-100) based on logging frequency and mood variance
  int getConsistencyScoreForFilter(String filter) {
    return _memoize('consistency_$filter', () {
      final entries = getEntriesForFilter(filter);
      if (entries.isEmpty) return 0;
      
      // 1. Logging consistency (days logged / total days in period)
      final dateMap = _getEntriesByDate(entries);
      if (dateMap.isEmpty) return 0;
      
      final sortedDates = dateMap.keys.toList()..sort();
      final firstDate = sortedDates.first;
      final lastDate = sortedDates.last;
      final daysInPeriod = lastDate.difference(firstDate).inDays + 1;
      
      // Cap at 30 days for reasonable scoring if period is huge
      final periodToUse = daysInPeriod > 30 ? 30 : (daysInPeriod < 7 ? 7 : daysInPeriod);
      
      double loggingScore = (dateMap.length / periodToUse) * 100;
      if (loggingScore > 100) loggingScore = 100;
      
      // We'll keep it simple and just use logging frequency as the "Consistency Score"
      return loggingScore.round();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
