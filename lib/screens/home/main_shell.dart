import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_theme_provider.dart';
import '../../providers/mood_provider.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final MoodProvider _moodProvider;

  @override
  void initState() {
    super.initState();
    _moodProvider = context.read<MoodProvider>();
    _moodProvider.addListener(_onMoodError);
  }

  void _onMoodError() {
    if (!mounted) return;
    
    final errorMessage = _moodProvider.errorMessage;
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _moodProvider.clearError();
    }
  }

  @override
  void dispose() {
    _moodProvider.removeListener(_onMoodError);
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodTheme = context.watch<MoodThemeProvider>();

    // Accent color adapts to active mood via theme override
    final accentColor = theme.colorScheme.primary;

    final screens = [
      HomeScreen(onViewInsights: () => _switchTab(2)),
      const HistoryScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              // Subtle mood gradient tint at the top of nav
              gradient: moodTheme.hasMood
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: 0.1),
                        theme.colorScheme.surface.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => _switchTab(0),
                      accentColor: accentColor,
                      theme: theme,
                    ),
                    _NavItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'History',
                      isSelected: _currentIndex == 1,
                      onTap: () => _switchTab(1),
                      accentColor: accentColor,
                      theme: theme,
                    ),
                    _NavItem(
                      icon: Icons.insights_rounded,
                      label: 'Insights',
                      isSelected: _currentIndex == 2,
                      onTap: () => _switchTab(2),
                      accentColor: accentColor,
                      theme: theme,
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isSelected: _currentIndex == 3,
                      onTap: () => _switchTab(3),
                      accentColor: accentColor,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Improvement #5: Nav item with adaptive mood accent for the active state.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final ThemeData theme;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? accentColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? accentColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
