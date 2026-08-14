import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/mood_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/mood_theme_provider.dart';
import '../../services/mood_trend_service.dart';
import '../../widgets/mood_card.dart';
import '../../widgets/adaptive_scaffold.dart';
import '../mood_detail/mood_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewInsights;

  const HomeScreen({super.key, this.onViewInsights});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onMoodTap(MoodData moodData) {
    // Auto-save mood entry immediately
    final moodProvider = context.read<MoodProvider>();
    moodProvider.addEntry(moodData.type);

    // Update the adaptive mood theme
    final moodTheme = context.read<MoodThemeProvider>();
    final auth = context.read<AuthProvider>();
    moodTheme.setMood(moodData.type, userId: auth.user?.uid);

    if (!mounted) return;

    // Navigate to detail screen (mood is already saved)
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MoodDetailScreen(moodData: moodData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final moodTheme = context.watch<MoodThemeProvider>();
    final trendService = context.read<MoodTrendService>();

    final rawName = auth.user?.name ?? '';
    final emailName = auth.user?.email.split('@').first ?? '';
    final validName = rawName.trim().isNotEmpty ? rawName : (emailName.isNotEmpty ? emailName : 'User');
    final userName = validName.split(' ').first;

    // Get greeting from GreetingService (time + mood aware)
    final greeting = moodTheme.greeting;

    // Analyze mood trends for the banner
    final weekEntries = moodProvider.getEntriesForWeek();
    final trend = trendService.analyze(weekEntries);

    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          // TopAppBar matching HTML design
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
                toolbarHeight: 64,
                title: Row(
                  children: [
                    // Profile avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: auth.user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                auth.user!.photoUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hello, $userName',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => _showComingSoon(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section — uses GreetingService
                        Text(
                          '${greeting.timeGreeting},\n$userName',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Mood-aware subtitle from GreetingService
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            greeting.moodMessage,
                            key: ValueKey(greeting.moodMessage),
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Mood Selection
                        Text(
                          'How are you feeling today?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Mood Cards Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final moodData = MoodData.allMoods[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 500 + (index * 80)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: MoodCard(
                          moodData: moodData,
                          onTap: () => _onMoodTap(moodData),
                        ),
                      );
                    },
                    childCount: MoodData.allMoods.length,
                  ),
                ),
              ),

              // Mood Trend Banner (when struggling or has pattern)
              if (trend.hasData && trend.adaptiveMessage.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                trend.isStruggling
                                    ? Icons.favorite_rounded
                                    : Icons.auto_awesome_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                trend.adaptiveMessage,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                sliver: SliverToBoxAdapter(
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
                    child: Column(
                      children: [
                        // Last Entry Card
                        if (moodProvider.lastEntry != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: MoodData.getMoodData(moodProvider.lastEntry!.mood)
                                        .lightColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      MoodData.getMoodData(moodProvider.lastEntry!.mood).emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last entry: ${_timeAgo(moodProvider.lastEntry!.date)}',
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        MoodData.getMoodData(moodProvider.lastEntry!.mood).name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // View Insights Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primaryContainer,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onViewInsights,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Text(
                                'View Insights',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
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
