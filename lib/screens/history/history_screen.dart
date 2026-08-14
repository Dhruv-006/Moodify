import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mood_model.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/adaptive_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;
  final _filters = ['Today', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = context.watch<MoodProvider>();

    List<MoodEntry> entries;
    switch (_selectedFilter) {
      case 0:
        entries = moodProvider.getEntriesForToday();
        break;
      case 1:
        entries = moodProvider.getEntriesForWeek();
        break;
      case 2:
        entries = moodProvider.getEntriesForMonth();
        break;
      default:
        entries = moodProvider.entries;
    }

    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          // Top AppBar matching HTML design
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              'Mood History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                onPressed: () => _showComingSoon(),
              ),
            ],
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: FilterChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedFilter = index);
                        },
                        backgroundColor: theme.colorScheme.surfaceContainerLow,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        showCheckmark: false,
                        elevation: isSelected ? 4 : 0,
                        shadowColor: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Entries List
          if (entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No mood entries yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start by logging your mood on the home screen',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = entries[index];
                    final moodData = MoodData.getMoodData(entry.mood);
                    final dateStr = DateFormat('d MMMM').format(entry.date);
                    final timeStr = DateFormat('h:mm a').format(entry.date);

                    // Staggered entrance animation (capped at 8 items)
                    final animDelay = (index < 8) ? index * 60 : 0;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + animDelay),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(entry.id ?? index),
                          direction: entry.id != null
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) {
                            moodProvider.deleteEntry(entry.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Mood entry deleted.',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mood Emoji Circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: moodData.lightColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      moodData.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              moodData.name,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: theme
                                                    .colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            dateStr,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12,
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (entry.note != null &&
                                          entry.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.note!,
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        timeStr,
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This mood entry will be permanently removed.',
          style: GoogleFonts.manrope(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon!',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
