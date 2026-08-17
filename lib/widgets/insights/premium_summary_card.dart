import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/mood_model.dart';

class PremiumSummaryCard extends StatelessWidget {
  final int totalEntries;
  final int streak;
  final MoodType? mostFrequent;
  final DateTime? bestDay;
  final DateTime? worstDay;
  final int consistencyScore;

  const PremiumSummaryCard({
    super.key,
    required this.totalEntries,
    required this.streak,
    required this.mostFrequent,
    required this.bestDay,
    required this.worstDay,
    required this.consistencyScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insights_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Monthly Summary',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Total Entries',
                  value: totalEntries.toString(),
                  icon: Icons.edit_note_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _SummaryMetric(
                  label: 'Longest Streak',
                  value: '$streak days',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Most Frequent',
                  value: mostFrequent != null ? MoodData.getMoodData(mostFrequent!).name : '-',
                  icon: Icons.pie_chart_rounded,
                  color: mostFrequent != null ? MoodData.getMoodData(mostFrequent!).color : theme.colorScheme.primary,
                ),
              ),
              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _SummaryMetric(
                  label: 'Consistency',
                  value: '$consistencyScore%',
                  icon: Icons.track_changes_rounded,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Best Day',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bestDay != null ? dateFormat.format(bestDay!) : '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: theme.colorScheme.outlineVariant),
                Column(
                  children: [
                    Text(
                      'Worst Day',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worstDay != null ? dateFormat.format(worstDay!) : '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
