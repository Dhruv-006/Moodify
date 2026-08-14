import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/mood_theme_model.dart';

/// A wrapper widget that applies a subtle, mood-specific animation to its child.
///
/// Animations are extremely subtle (2–5px movement, 0.97–1.03 scale) to
/// maintain a premium, non-distracting feel.
///
/// Respects [MediaQuery.disableAnimations] for accessibility.
class MoodAnimatedContainer extends StatefulWidget {
  final MoodAnimation animation;
  final Widget child;
  final Duration duration;

  const MoodAnimatedContainer({
    super.key,
    required this.animation,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<MoodAnimatedContainer> createState() => _MoodAnimatedContainerState();
}

class _MoodAnimatedContainerState extends State<MoodAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect accessibility: disable animations if requested
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _applyAnimation(child!);
      },
      child: widget.child,
    );
  }

  Widget _applyAnimation(Widget child) {
    final value = _controller.value;

    switch (widget.animation) {
      case MoodAnimation.bounce:
        // Soft scale oscillation: 1.0 → 1.02 → 1.0
        final scale = 1.0 + (0.02 * _sineEase(value));
        return Transform.scale(scale: scale, child: child);

      case MoodAnimation.fade:
        // Slow opacity pulse: 0.92 → 1.0 → 0.92
        final opacity = 0.92 + (0.08 * _sineEase(value));
        return Opacity(opacity: opacity, child: child);

      case MoodAnimation.pulse:
        // Gentle scale throb: 0.98 → 1.01 → 0.98
        final scale = 0.98 + (0.03 * _sineEase(value));
        return Transform.scale(scale: scale, child: child);

      case MoodAnimation.breathing:
        // Slow scale in/out: 0.97 → 1.03 → 0.97
        final scale = 0.97 + (0.06 * _sineEase(value));
        return Transform.scale(scale: scale, child: child);

      case MoodAnimation.floating:
        // Vertical drift: ±3px
        final offset = Offset(0, 3.0 * (2.0 * _sineEase(value) - 1.0));
        return Transform.translate(offset: offset, child: child);

      case MoodAnimation.upward:
        // Gentle upward rise: 0 → -4px → 0
        final offset = Offset(0, -4.0 * _sineEase(value));
        return Transform.translate(offset: offset, child: child);
    }
  }

  /// Smooth sine-based easing for natural motion.
  double _sineEase(double t) {
    return (1.0 - math.cos(t * 3.14159 * 2.0)) / 2.0;
  }
}
