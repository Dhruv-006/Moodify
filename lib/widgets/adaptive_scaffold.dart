import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_theme_provider.dart';
import 'mood_background_painter.dart';

/// A global wrapper that replaces [Scaffold] to provide a unified, mood-aware
/// adaptive background experience across all main screens.
class AdaptiveScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const AdaptiveScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodTheme = context.watch<MoodThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;

    // Base background color (White or Dark Gray)
    final baseColor = theme.scaffoldBackgroundColor;
    final accent = moodTheme.hasMood ? moodTheme.currentConfig.accent : Colors.transparent;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Base Solid Background
        Container(color: baseColor),

        // 2. Layer 1: Soft Top-Center Radial Glow
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.8), // Top center
              radius: 1.8,
              colors: [
                accent.withValues(alpha: isDark ? 0.15 : 0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),

        // 3. Layer 2: Subtle Bottom-Right Ambient (Linear)
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                accent.withValues(alpha: isDark ? 0.08 : 0.05),
              ],
            ),
          ),
        ),

        // 2. Animated particle effects (subtle mood animations)
        if (moodTheme.hasMood)
          MoodAnimatedBackground(
            mood: moodTheme.activeMood!,
            accentColor: moodTheme.currentConfig.accent,
          ),

        // 3. The actual Scaffold (transparent to show backgrounds)
        Scaffold(
          backgroundColor: Colors.transparent,
          body: body,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        ),
      ],
    );
  }
}
