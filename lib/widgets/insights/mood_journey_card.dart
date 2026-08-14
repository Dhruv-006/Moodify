import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodJourneyCard extends StatelessWidget {
  final List<String> observations;

  const MoodJourneyCard({super.key, required this.observations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Mood Journey',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...observations.asMap().entries.map((entry) {
            final idx = entry.key;
            final observation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (idx * 200)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        observation,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
