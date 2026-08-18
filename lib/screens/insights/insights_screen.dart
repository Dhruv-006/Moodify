import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/mood_model.dart';
import '../../providers/mood_provider.dart';
import '../../services/mood_trend_service.dart';
import '../../widgets/adaptive_scaffold.dart';
import '../../widgets/insights/premium_summary_card.dart';
import '../../widgets/insights/mood_journey_card.dart';
import '../../widgets/insights/ai_insight_card.dart';
import '../../widgets/insights/mood_calendar_view.dart';
import '../../widgets/insights/empty_insights_view.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedFilter = 2; // Default: This Month
  final _filters = ['Today', 'This Week', 'This Month', 'Last Month', 'All Time'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodProvider = context.watch<MoodProvider>();

    // Get filtered entries based on selected filter
    final filterName = _filters[_selectedFilter];
    final filteredEntries = moodProvider.getEntriesForFilter(filterName);



    final distribution = moodProvider.getMoodDistributionForFilter(filterName);
    final weeklyCounts = moodProvider.getWeeklyMoodCountsForFilter(filterName);
    final monthlyBarData = moodProvider.getMonthlyBarDataForFilter(filterName);

    final monthlyMaxY = (monthlyBarData.values.fold<int>(0, (a, dayMap) {
      final dayTotal = dayMap.values.fold<int>(0, (sum, count) => sum + count);
      return a > dayTotal ? a : dayTotal;
    }) + 1).toDouble();
    double monthlyYInterval = 1;
    if (monthlyMaxY > 20) {
      monthlyYInterval = 10;
    } else if (monthlyMaxY > 10) {
      monthlyYInterval = 5;
    } else if (monthlyMaxY > 5) {
      monthlyYInterval = 2;
    }

    final weeklyMaxY = (weeklyCounts.values.fold<int>(0, (a, dayMap) {
      final dayTotal = dayMap.values.fold<int>(0, (sum, count) => sum + count);
      return a > dayTotal ? a : dayTotal;
    }) + 1).toDouble();
    double weeklyYInterval = 1;
    if (weeklyMaxY > 20) {
      weeklyYInterval = 10;
    } else if (weeklyMaxY > 10) {
      weeklyYInterval = 5;
    } else if (weeklyMaxY > 5) {
      weeklyYInterval = 2;
    }

    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          // Top AppBar
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
              'Your Mood Insights',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),


          // Filter Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          if (filteredEntries.isEmpty)
            const EmptyInsightsView()
          else ...[
            // Premium Summary Card
            SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: PremiumSummaryCard(
                totalEntries: filteredEntries.length,
                streak: moodProvider.getStreakForFilter(filterName),
                mostFrequent: moodProvider.getMostFrequentMoodForFilter(filterName),
                bestDay: moodProvider.getBestDayForFilter(filterName),
                worstDay: moodProvider.getWorstDayForFilter(filterName),
                consistencyScore: moodProvider.getConsistencyScoreForFilter(filterName),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          // Mood Calendar View
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: MoodCalendarView(
                entriesByDate: moodProvider.getEntriesByDate(filteredEntries),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Charts Section Header — animated
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                    'Data Overview',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pie Chart — animated
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
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
                  child: _ChartCard(
                    title: 'Mood Distribution',
                    child: distribution.isNotEmpty
                        ? Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: distribution.entries.map((e) {
                                      final data = MoodData.getMoodData(e.key);
                                      final total = distribution.values
                                          .fold(0, (a, b) => a + b);
                                      final percentage =
                                          (e.value / total * 100).round();
                                      return PieChartSectionData(
                                        color: data.color,
                                        value: e.value.toDouble(),
                                        title: '$percentage%',
                                        titleStyle: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        radius: 60,
                                        badgePositionPercentageOffset: 0.98,
                                      );
                                    }).toList(),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: distribution.keys.map((type) {
                                  final data = MoodData.getMoodData(type);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: data.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        data.emoji,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data.name,
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          )
                        : _EmptyChart(message: 'Log moods to see distribution'),
                  ),
                ),
                const SizedBox(height: 16),

                // Monthly Bar Chart — animated
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 850),
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
                  child: _ChartCard(
                    title: 'Monthly Overview',
                    child: monthlyBarData.values.any((dayMap) => dayMap.values.any((count) => count > 0))
                        ? SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: monthlyMaxY,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        'Day ${group.x}: ${rod.toY.toInt()} entries',
                                        GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() % 5 == 1 || value.toInt() == 1) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              '${value.toInt()}',
                                              style: GoogleFonts.manrope(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == value.toInt().toDouble() && value > 0) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: GoogleFonts.manrope(
                                              fontSize: 10,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                      reservedSize: 24,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: monthlyYInterval,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                    strokeWidth: 1,
                                    dashArray: [4, 4], // Dashed grid line for a softer look
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: monthlyBarData.entries.toList().map((e) {
                                  final dayMap = e.value;
                                  double currentY = 0;
                                  final stackItems = <BarChartRodStackItem>[];
                                  for(final mood in dayMap.keys) {
                                    final val = dayMap[mood]!.toDouble();
                                    stackItems.add(BarChartRodStackItem(currentY, currentY + val, MoodData.getMoodData(mood).color));
                                    currentY += val;
                                  }

                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: currentY,
                                        width: 10,
                                        borderRadius: BorderRadius.circular(100),
                                        rodStackItems: stackItems,
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: monthlyMaxY,
                                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : _EmptyChart(message: 'Log moods to see monthly chart'),
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Flow Bar Chart — animated
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
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
                  child: _ChartCard(
                    title: 'Weekly Flow',
                    child: weeklyCounts.values.any((dayMap) => dayMap.values.any((count) => count > 0))
                        ? SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: weeklyMaxY,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.toInt()} entries',
                                        GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final days = weeklyCounts.keys.toList();
                                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              days[value.toInt()],
                                              style: GoogleFonts.manrope(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: weeklyYInterval,
                                      getTitlesWidget: (value, meta) {
                                        if (value == value.toInt().toDouble() && value > 0) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: GoogleFonts.manrope(
                                              fontSize: 10,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                      reservedSize: 24,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: weeklyYInterval,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: weeklyCounts.entries.toList().asMap().entries.map((e) {
                                  final dayMap = e.value.value;
                                  double currentY = 0;
                                  final stackItems = <BarChartRodStackItem>[];
                                  for(final mood in dayMap.keys) {
                                    final val = dayMap[mood]!.toDouble();
                                    stackItems.add(BarChartRodStackItem(currentY, currentY + val, MoodData.getMoodData(mood).color));
                                    currentY += val;
                                  }

                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: currentY,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(100),
                                        rodStackItems: stackItems,
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: weeklyMaxY,
                                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : _EmptyChart(message: 'Log moods to see weekly flow'),
                  ),
                ),
                const SizedBox(height: 32),

                // AI Insight Card
                Builder(
                  builder: (context) {
                    final trendService = context.read<MoodTrendService>();
                    final trend = trendService.analyze(filteredEntries);
                    if (trend.insightMessage.isEmpty) return const SizedBox.shrink();
                    
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: AiInsightCard(
                        insightMessage: trend.insightMessage,
                        isStruggling: trend.isStruggling,
                      ),
                    );
                  }
                ),

                const SizedBox(height: 24),

                // Mood Journey Card
                Builder(
                  builder: (context) {
                    final trendService = context.read<MoodTrendService>();
                    final observations = trendService.getMoodJourneyObservations(filteredEntries);
                    
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: MoodJourneyCard(observations: observations),
                    );
                  }
                ),
              ]),
            ),
          ),
          ],
        ],
      ),
    );
  }

}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

