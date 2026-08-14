import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mood_model.dart';

/// A subtle animated background that renders mood-specific particle effects.
///
/// Improvement #4: Dynamic animated backgrounds.
///
/// Requirements enforced:
/// - Max 12 particles
/// - Alpha values capped at 0.08–0.15 (extremely subtle)
/// - Respects [MediaQuery.disableAnimations]
/// - Does NOT block touch events ([IgnorePointer])
/// - Uses [RepaintBoundary] for GPU efficiency
class MoodAnimatedBackground extends StatefulWidget {
  final MoodType mood;
  final Color accentColor;

  const MoodAnimatedBackground({
    super.key,
    required this.mood,
    required this.accentColor,
  });

  @override
  State<MoodAnimatedBackground> createState() => _MoodAnimatedBackgroundState();
}

class _MoodAnimatedBackgroundState extends State<MoodAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random(42); // Fixed seed for deterministic layout

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(MoodAnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _particles = _generateParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Particle> _generateParticles() {
    final count = switch (widget.mood) {
      MoodType.happy => 6,      // Fewer, larger orbs
      MoodType.sad => 8,        // Soft slow drifts
      MoodType.angry => 2,      // Deep pulsing shapes
      MoodType.stressed => 5,   // Soft breathing waves
      MoodType.relaxed => 6,    // Organic floating shapes
      MoodType.motivated => 8,  // Upward premium lights
    };
    return List.generate(count, (i) => _Particle.random(_random));
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const SizedBox.expand();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _MoodBackgroundPainter(
                mood: widget.mood,
                color: widget.accentColor,
                progress: _controller.value,
                particles: _particles,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _MoodBackgroundPainter extends CustomPainter {
  final MoodType mood;
  final Color color;
  final double progress;
  final List<_Particle> particles;

  _MoodBackgroundPainter({
    required this.mood,
    required this.color,
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case MoodType.happy:
        _paintFloatingCircles(canvas, size);
      case MoodType.sad:
        _paintSoftRain(canvas, size);
      case MoodType.angry:
        _paintPulsingGlow(canvas, size);
      case MoodType.stressed:
        _paintBreathingWaves(canvas, size);
      case MoodType.relaxed:
        _paintFloatingLeaves(canvas, size);
      case MoodType.motivated:
        _paintUpwardParticles(canvas, size);
    }
  }

  /// Happy: Large, warm, slow-floating orbs (energy)
  void _paintFloatingCircles(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24); // Soft glow

    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      final x = p.x * size.width + sin(phase * pi * 2) * 40;
      final y = p.y * size.height + cos(phase * pi * 2 * 0.5) * 30;
      final radius = p.size * 60 + 40; // Much larger
      final alpha = (0.05 + p.size * 0.08).clamp(0.0, 0.15);

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  /// Sad: Slow, soft downward drifting organic shapes (calm)
  void _paintSoftRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      final x = p.x * size.width + sin(phase * pi * 2) * 20;
      final y = (phase * 1.2 % 1.0) * size.height * 1.5 - size.height * 0.2;
      final radius = p.size * 50 + 30;
      final alpha = (0.04 + p.size * 0.06).clamp(0.0, 0.12);

      paint.color = color.withValues(alpha: alpha);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: radius * 0.8, height: radius * 1.5),
        paint,
      );
    }
  }

  /// Angry: Deep, slow-pulsing shapes (powerful but controlled)
  void _paintPulsingGlow(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final phase = (progress + p.phase) % 1.0;
      final pulse = sin(phase * pi * 2);
      final alpha = (0.05 + 0.08 * pulse).clamp(0.0, 0.15);
      
      final x = p.x * size.width + cos(phase * pi) * 20;
      final y = p.y * size.height + sin(phase * pi) * 20;
      final radius = size.width * 0.6 + (pulse * 40);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  /// Stressed: Soft, breathing waves with larger amplitude (comforting)
  void _paintBreathingWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final phase = (progress + p.phase) % 1.0;
      final breath = sin(phase * pi * 2);
      final alpha = (0.04 + 0.06 * breath).clamp(0.0, 0.12);
      
      paint.color = color.withValues(alpha: alpha);
      final path = Path();
      final yBase = size.height * (0.2 + i * 0.15);
      final amplitude = 20.0 + 10.0 * breath;

      for (double x = 0; x < size.width; x += 10) {
        final y = yBase + sin(x * 0.01 + phase * pi * 2) * amplitude;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.quadraticBezierTo(x - 5, yBase + sin((x - 5) * 0.01 + phase * pi * 2) * amplitude, x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  /// Relaxed: Gentle floating organic shapes (peaceful)
  void _paintFloatingLeaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      final x = p.x * size.width + sin(phase * pi * 2) * 50;
      final y = p.y * size.height + cos(phase * pi * 2 * 0.6) * 40;
      final rotation = phase * pi * 2;
      final alpha = (0.04 + p.size * 0.08).clamp(0.0, 0.12);

      paint.color = color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 40 * p.size + 30, height: 20 * p.size + 15),
        paint,
      );
      canvas.restore();
    }
  }

  /// Motivated: Inspiring upward-moving light particles with soft trails
  void _paintUpwardParticles(Canvas canvas, Size size) {
    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      // Particles rise from bottom to top slowly
      final x = p.x * size.width + sin(phase * pi * 4) * 20;
      final y = size.height * (1.2 - phase * 1.4);
      final radius = p.size * 15 + 8;
      
      // Fade in and out
      final alpha = (sin(phase * pi) * 0.15).clamp(0.0, 0.15);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      // Draw a soft glowing orb
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MoodBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mood != mood ||
        oldDelegate.color != color;
  }
}

/// A single particle with randomized position, size, and phase offset.
class _Particle {
  final double x;     // 0.0 – 1.0
  final double y;     // 0.0 – 1.0
  final double size;  // 0.0 – 1.0
  final double phase; // 0.0 – 1.0

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });

  factory _Particle.random(Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 0.3 + random.nextDouble() * 0.7,
      phase: random.nextDouble(),
    );
  }
}
