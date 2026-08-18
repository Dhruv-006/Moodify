import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  bool _isRunning = false;
  String _phase = 'Ready';
  int _phaseSeconds = 0;

  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 4;
  static const int _exhaleSeconds = 4;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      // Inhale: scale up (0-4s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inhaleSeconds.toDouble(),
      ),
      // Hold: stay big (4-8s)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: _holdSeconds.toDouble(),
      ),
      // Exhale: scale down (8-12s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _exhaleSeconds.toDouble(),
      ),
    ]).animate(_breathController);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _breathController.addListener(_updatePhase);
  }

  void _updatePhase() {
    final value = _breathController.value;
    final totalDuration = _inhaleSeconds + _holdSeconds + _exhaleSeconds;
    final currentTime = value * totalDuration;

    String newPhase;
    int seconds;

    if (currentTime < _inhaleSeconds) {
      newPhase = 'Inhale';
      seconds = (_inhaleSeconds - currentTime).ceil();
    } else if (currentTime < _inhaleSeconds + _holdSeconds) {
      newPhase = 'Hold';
      seconds = (_inhaleSeconds + _holdSeconds - currentTime).ceil();
    } else {
      newPhase = 'Exhale';
      seconds = (totalDuration - currentTime).ceil();
    }

    if (_phase != newPhase || _phaseSeconds != seconds) {
      setState(() {
        _phase = newPhase;
        _phaseSeconds = seconds;
      });
    }
  }

  void _toggleBreathing() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _breathController.repeat();
      } else {
        _breathController.stop();
        _phase = 'Paused';
      }
    });
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _breathController.stop();
      _breathController.reset();
      _phase = 'Ready';
      _phaseSeconds = 0;
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: Column(
          children: [
            // AppBar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Mindful Breath',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: Stack(
                children: [
                  // Background ambient glow
                  Center(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.secondary
                                    .withValues(alpha: _glowAnimation.value * 0.2),
                                theme.colorScheme.surface.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),

                      // Breathing Circle
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          final scale = _isRunning ? _scaleAnimation.value : 0.7;
                          return Transform.scale(
                            scale: scale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow rings
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        theme.colorScheme.secondary
                                            .withValues(alpha: 0.2),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        theme.colorScheme.tertiary
                                            .withValues(alpha: 0.2),
                                        theme.colorScheme.secondary
                                            .withValues(alpha: 0.15),
                                      ],
                                    ),
                                  ),
                                ),
                                // Main circle
                                Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.primaryContainer,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.2),
                                        blurRadius: 64,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _phase,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Spacer(flex: 1),

                      // Timer indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          '${_inhaleSeconds}s • ${_holdSeconds}s • ${_exhaleSeconds}s',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stop button
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.stop_rounded,
                                color: theme.colorScheme.onSecondaryContainer,
                                size: 28,
                              ),
                              onPressed: _stopBreathing,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Play/Pause button
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: _toggleBreathing,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Pause button placeholder
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.pause_rounded,
                                color: theme.colorScheme.onSecondaryContainer,
                                size: 28,
                              ),
                              onPressed:
                                  _isRunning ? _toggleBreathing : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Motivational line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Take a deep breath. You are safe.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
