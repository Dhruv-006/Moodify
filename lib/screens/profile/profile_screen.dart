import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/mood_model.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../../widgets/adaptive_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    final auth = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    if (user == null) return const SizedBox();

    final totalEntries = moodProvider.entries.length;
    final streak = moodProvider.getStreak();
    final mostFrequent = moodProvider.getMostFrequentMood();

    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
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
              'Profile',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _showComingSoon(),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Header — animated
                TweenAnimationBuilder<double>(
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
                    children: [
                      // Avatar
                      Builder(
                        builder: (context) {
                          final rawName = user.name;
                          final emailName = user.email.split('@').first;
                          final displayFullName = rawName.trim().isNotEmpty
                              ? rawName
                              : emailName;

                          return Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      theme.colorScheme.surfaceContainerLowest,
                                  border: Border.all(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.06),
                                      blurRadius: 64,
                                      offset: const Offset(0, 32),
                                    ),
                                  ],
                                ),
                                child: user.photoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user.photoUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          displayFullName.isNotEmpty
                                              ? displayFullName[0].toUpperCase()
                                              : 'U',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayFullName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Row — animated counters
                TweenAnimationBuilder<double>(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: _AnimatedStatCard(
                          targetValue: totalEntries,
                          label: 'Mood Entries',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedStatCard(
                          targetValue: streak,
                          label: 'Day Streak',
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCardEmoji(
                          emoji: mostFrequent != null
                              ? MoodData.getMoodData(mostFrequent).emoji
                              : '😶',
                          label: mostFrequent != null
                              ? MoodData.getMoodData(mostFrequent).name
                              : 'N/A',
                          color: mostFrequent != null
                              ? MoodData.getMoodData(mostFrequent).color
                              : theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Options — animated
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: Column(
                    children: [
                      _OptionTile(
                        icon: Icons.edit_rounded,
                        title: 'Edit Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _OptionTile(
                        icon: Icons.palette_rounded,
                        title: 'Change Theme',
                        trailing: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(
                                Icons.brightness_auto_rounded,
                                size: 16,
                              ),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                            ),
                          ],
                          selected: {themeProvider.themeMode},
                          onSelectionChanged: (modes) {
                            themeProvider.setThemeMode(modes.first);
                          },
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _OptionTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notification Settings',
                        onTap: () => _showComingSoon(),
                      ),
                      const SizedBox(height: 12),
                      _OptionTile(
                        icon: Icons.lock_rounded,
                        title: 'Privacy Settings',
                        onTap: () => _showComingSoon(),
                      ),
                      const SizedBox(height: 24),

                      // Logout
                      GestureDetector(
                        onTap: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer
                                      .withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Logout',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
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

// ── Animated counting stat card ──
class _AnimatedStatCard extends StatelessWidget {
  final int targetValue;
  final String label;
  final Color color;

  const _AnimatedStatCard({
    required this.targetValue,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: targetValue),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Stat card with emoji instead of number ──
class _StatCardEmoji extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _StatCardEmoji({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
