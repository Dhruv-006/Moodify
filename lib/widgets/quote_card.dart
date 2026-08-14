import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  final Color accentColor;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: accentColor.withValues(alpha: 0.6),
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: accentColor.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
