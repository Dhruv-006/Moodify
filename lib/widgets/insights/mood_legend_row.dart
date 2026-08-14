import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/mood_model.dart';

class MoodLegendRow extends StatelessWidget {
  const MoodLegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: MoodType.values.map((mood) {
          final data = MoodData.getMoodData(mood);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: data.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  data.name,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
