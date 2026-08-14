import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/adaptive_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/mood_theme_provider.dart';
import 'services/mood_recommendation_service.dart';
import 'services/music_launcher_service.dart';
import 'services/greeting_service.dart';
import 'services/mood_trend_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/splash/splash_screen.dart';

import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for future third-party APIs
  await EnvConfig.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local mood persistence
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.moodPrefsBox);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MoodifyApp());
}

class MoodifyApp extends StatefulWidget {
  const MoodifyApp({super.key});

  @override
  State<MoodifyApp> createState() => _MoodifyAppState();
}

class _MoodifyAppState extends State<MoodifyApp> {
  bool _hasShownSplash = false;

  void _onSplashComplete() {
    setState(() => _hasShownSplash = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MoodProvider>(
          create: (_) => MoodProvider(),
          update: (_, auth, moodProvider) {
            moodProvider!.setUser(auth.isLoggedIn ? auth.user?.uid : null);
            return moodProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, MoodThemeProvider>(
          create: (_) => MoodThemeProvider(),
          update: (_, auth, moodTheme) {
            moodTheme!.setUserId(auth.isLoggedIn ? auth.user?.uid : null);
            return moodTheme;
          },
        ),
        Provider<MoodRecommendationService>(
          create: (_) => MoodRecommendationService(),
        ),
        Provider<MusicLauncherService>(create: (_) => MusicLauncherService()),
        Provider<GreetingService>(create: (_) => GreetingService()),
        Provider<MoodTrendService>(create: (_) => MoodTrendService()),
      ],
      child: Consumer3<ThemeProvider, MoodThemeProvider, AuthProvider>(
        builder: (context, themeProvider, moodTheme, auth, child) {
          return MaterialApp(
            key: ValueKey(auth.isLoggedIn),
            title: 'Moodify',
            debugShowCheckedModeBanner: false,
            theme: AdaptiveTheme.applyMoodAccent(
              AppTheme.lightTheme(),
              moodTheme.currentConfig,
            ),
            darkTheme: AdaptiveTheme.applyMoodAccent(
              AppTheme.darkTheme(),
              moodTheme.currentConfig,
            ),
            themeMode: themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 600),
            themeAnimationCurve: Curves.easeOutCubic,
            home: !_hasShownSplash
                ? SplashScreen(onComplete: _onSplashComplete)
                : (auth.isLoggedIn ? const MainShell() : const LoginScreen()),
          );
        },
      ),
    );
  }
}
