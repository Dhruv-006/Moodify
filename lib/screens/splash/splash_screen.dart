import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _taglineFade;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 0–1s: Logo fades in
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    // 1–2s: Logo scales smoothly
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.14, 0.57, curve: Curves.easeOutCubic),
      ),
    );

    // 2–3s: Glow effect
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // 2–3s: Tagline fades in
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.57, 0.80, curve: Curves.easeOut),
      ),
    );

    // 3–3.5s: Exit fade
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _masterController.forward();

    // Start glow at ~2s
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _glowController.repeat(reverse: true);
      }
    });

    // Navigate after animation
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToApp();
      }
    });
  }

  void _navigateToApp() {
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_masterController, _glowController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              children: [
                // Ambient background blobs (matching login screen style)
                Positioned(
                  top: -size.height * 0.15,
                  left: -size.width * 0.15,
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -size.height * 0.15,
                  right: -size.width * 0.15,
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.25),
                    ),
                  ),
                ),

                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing logo container
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow layer
                              FadeTransition(
                                opacity: _glowOpacity,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Logo circle
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                      theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.4),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.psychology_rounded,
                                  size: 72,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Brand name
                      FadeTransition(
                        opacity: _logoFade,
                        child: Text(
                          'Moodify',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Track your mood. Transform your day.',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
