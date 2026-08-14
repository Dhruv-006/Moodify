import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration class for all environment variables and API keys.
/// No third-party API credentials should be hardcoded anywhere else in the application.
class EnvConfig {
  static Future<void> init() async {
    // Attempt to load .env. Will not crash if .env is missing to prevent breaking production
    // if secrets are injected via CI/CD instead.
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Ignore if file not found
    }
  }

  // Example for future integrations:
  // static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  // static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  // static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
}
