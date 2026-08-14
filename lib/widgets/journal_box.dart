import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalBox extends StatelessWidget {
  final String prompt;
  final TextEditingController controller;
  final Color accentColor;
  final VoidCallback? onSave;

  const JournalBox({
    super.key,
    required this.prompt,
    required this.controller,
    required this.accentColor,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prompt,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Write your thoughts here...',
              hintStyle: GoogleFonts.manrope(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor.withValues(alpha: 0.15),
              foregroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save_rounded, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Save Note',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
