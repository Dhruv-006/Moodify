import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyInsightsView extends StatelessWidget {
  const EmptyInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.query_stats_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No mood entries yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your mood today to unlock insights.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the "Log Mood" screen or switch tab to Home.
                // Assuming MainShell can be accessed, or we just rely on bottom nav.
                // For now, this could just show a snackbar or trigger a callback if needed.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Go to the Home tab to log a mood!")),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Track Mood'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
