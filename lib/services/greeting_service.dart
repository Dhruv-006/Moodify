import '../models/mood_model.dart';

/// Generates contextual greetings based on both time-of-day and active mood.
///
/// Improvement #2: Greeting depends on both time AND mood, not just mood.
/// Improvement #8: The API is async-ready for future AI-generated greetings.
class GreetingService {
  /// Generate a greeting result combining time and mood context.
  GreetingResult getGreeting(MoodType? mood) {
    final timeGreeting = _getTimeGreeting();
    final moodMessage = _getMoodMessage(mood, _getTimeOfDay());
    return GreetingResult(
      timeGreeting: timeGreeting,
      moodMessage: moodMessage,
    );
  }

  /// Async variant for future AI compatibility.
  Future<GreetingResult> getGreetingAsync(MoodType? mood) async {
    return getGreeting(mood);
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 22) return 'Good Evening';
    return 'Good Night';
  }

  _TimeOfDay _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return _TimeOfDay.morning;
    if (hour >= 12 && hour < 17) return _TimeOfDay.afternoon;
    if (hour >= 17 && hour < 22) return _TimeOfDay.evening;
    return _TimeOfDay.night;
  }

  String _getMoodMessage(MoodType? mood, _TimeOfDay time) {
    if (mood == null) return "Let's check in with yourself today.";

    return switch ((mood, time)) {
      // Happy
      (MoodType.happy, _TimeOfDay.morning) => "You're glowing today!",
      (MoodType.happy, _TimeOfDay.afternoon) => "Keep this beautiful energy going!",
      (MoodType.happy, _TimeOfDay.evening) => "What a beautiful day it's been!",
      (MoodType.happy, _TimeOfDay.night) => "Sweet dreams — you earned today's joy!",

      // Sad
      (MoodType.sad, _TimeOfDay.morning) => "A fresh start awaits. Take it slow.",
      (MoodType.sad, _TimeOfDay.afternoon) => "Be gentle with yourself this afternoon.",
      (MoodType.sad, _TimeOfDay.evening) => "Allow yourself to rest tonight.",
      (MoodType.sad, _TimeOfDay.night) => "Tomorrow is a brand new start.",

      // Angry
      (MoodType.angry, _TimeOfDay.morning) => "Channel the morning energy positively.",
      (MoodType.angry, _TimeOfDay.afternoon) => "Take a pause. Breathe deeply.",
      (MoodType.angry, _TimeOfDay.evening) => "Let the evening calm settle in.",
      (MoodType.angry, _TimeOfDay.night) => "Let go. The night is for healing.",

      // Stressed
      (MoodType.stressed, _TimeOfDay.morning) => "Take today one step at a time.",
      (MoodType.stressed, _TimeOfDay.afternoon) => "Let's slow things down a little.",
      (MoodType.stressed, _TimeOfDay.evening) => "You've done enough today.",
      (MoodType.stressed, _TimeOfDay.night) => "You've done enough today. Let yourself rest.",

      // Relaxed
      (MoodType.relaxed, _TimeOfDay.morning) => "What a peaceful morning.",
      (MoodType.relaxed, _TimeOfDay.afternoon) => "Enjoy this calm afternoon moment.",
      (MoodType.relaxed, _TimeOfDay.evening) => "Take this peaceful moment to recharge.",
      (MoodType.relaxed, _TimeOfDay.night) => "Drift into peaceful sleep.",

      // Motivated
      (MoodType.motivated, _TimeOfDay.morning) => "Today's a great day to build something amazing.",
      (MoodType.motivated, _TimeOfDay.afternoon) => "Keep the momentum going!",
      (MoodType.motivated, _TimeOfDay.evening) => "Reflect on today's wins.",
      (MoodType.motivated, _TimeOfDay.night) => "Rest well. Tomorrow is yours to conquer.",
    };
  }
}

/// The result of a greeting generation.
class GreetingResult {
  /// Time-based greeting, e.g. "Good Morning ☀️"
  final String timeGreeting;

  /// Mood-specific contextual message, e.g. "You're glowing today!"
  final String moodMessage;

  const GreetingResult({
    required this.timeGreeting,
    required this.moodMessage,
  });
}

enum _TimeOfDay { morning, afternoon, evening, night }
