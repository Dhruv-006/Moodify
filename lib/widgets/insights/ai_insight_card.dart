import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiInsightCard extends StatelessWidget {
  final String insightMessage;
  final bool isStruggling;

  const AiInsightCard({
    super.key,
    required this.insightMessage,
    required this.isStruggling,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isStruggling
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.2)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isStruggling
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isStruggling
                  ? theme.colorScheme.error.withValues(alpha: 0.15)
                  : theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isStruggling ? Icons.favorite_rounded : Icons.auto_awesome_rounded,
              color: isStruggling ? theme.colorScheme.error : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Insight",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isStruggling ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insightMessage,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
