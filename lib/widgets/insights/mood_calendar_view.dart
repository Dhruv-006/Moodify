import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/mood_model.dart';

class MoodCalendarView extends StatelessWidget {
  final Map<DateTime, List<MoodEntry>> entriesByDate;

  const MoodCalendarView({super.key, required this.entriesByDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust weekday so Sunday is 0 or 7 depending on preference. 
    // Let's make Monday = 1, Sunday = 7
    final emptyPrefixSlots = firstWeekday - 1;

    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Mood Calendar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekdays header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: emptyPrefixSlots + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < emptyPrefixSlots) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - emptyPrefixSlots + 1;
              final currentDate = DateTime(now.year, now.month, dayNumber);
              
              // Normalize the date to match the map keys
              final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
              final dayEntries = entriesByDate[normalizedDate] ?? [];
              
              MoodType? dominantMood;
              if (dayEntries.isNotEmpty) {
                final counts = <MoodType, int>{};
                for (var e in dayEntries) {
                  counts[e.mood] = (counts[e.mood] ?? 0) + 1;
                }
                dominantMood = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
              }

              final isToday = currentDate.day == now.day && currentDate.month == now.month && currentDate.year == now.year;

              return InkWell(
                onTap: dayEntries.isNotEmpty
                    ? () => _showDayDetails(context, currentDate, dayEntries)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday 
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNumber.toString(),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (dominantMood != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: MoodData.getMoodData(dominantMood).color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, List<MoodEntry> entries) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, MMMM d').format(date);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
              formattedDate,
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final moodData = MoodData.getMoodData(entry.mood);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: moodData.color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(moodData.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(
                              moodData.name,
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: moodData.color),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('h:mm a').format(entry.date),
                              style: GoogleFonts.manrope(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(entry.note!, style: GoogleFonts.manrope(fontSize: 14, color: theme.colorScheme.onSurface)),
                        ],
                        if (entry.activities.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: entry.activities.map((a) => Chip(
                              label: Text(a, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: theme.colorScheme.surfaceContainerHigh,
                              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            )).toList(),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
