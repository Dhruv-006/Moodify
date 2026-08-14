import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/mood_model.dart';
import '../../providers/mood_provider.dart';
import '../../services/mood_recommendation_service.dart';
import '../../widgets/music_tile.dart';
import '../../widgets/mood_background_painter.dart';
import '../../core/theme/mood_theme_repository.dart';
import '../../widgets/adaptive_scaffold.dart';
import '../breathing/breathing_screen.dart';

class MoodDetailScreen extends StatefulWidget {
  final MoodData moodData;

  const MoodDetailScreen({super.key, required this.moodData});

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen>
    with TickerProviderStateMixin {
  final _journalController = TextEditingController();
  Timer? _debounce;
  String _saveStatus = '';
  late MoodProvider _moodProvider;
  late AnimationController _masterController;
  late AnimationController _emojiController;
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  // Dynamic payload states
  String? _dynamicMessage;
  String? _dynamicJournalPrompt;
  List<Map<String, String>>? _dynamicQuotes;
  List<Map<String, dynamic>>? _dynamicActivities;
  List<Map<String, String>>? _dynamicMusic;

  // Staggered animations
  late Animation<double> _emojiFade;
  late Animation<double> _activitiesFade;
  late Animation<Offset> _activitiesSlide;
  late Animation<double> _quotesFade;
  late Animation<Offset> _quotesSlide;
  late Animation<double> _musicFade;
  late Animation<Offset> _musicSlide;
  late Animation<double> _journalFade;
  late Animation<Offset> _journalSlide;
  late Animation<double> _emojiScale;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _emojiController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: const Offset(0, 0.08),
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    // Emoji fade + scale
    _emojiFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _emojiController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _emojiScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _emojiController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Activities: 0.0 – 0.4
    _activitiesFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _activitiesSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    // Quotes: 0.2 – 0.55
    _quotesFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _quotesSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    // Music: 0.35 – 0.7
    _musicFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    _musicSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    ));

    // Journal: 0.5 – 0.85
    _journalFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    _journalSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    ));

    _emojiController.forward();
    _masterController.forward();

    // Auto-save listener with debounce
    _journalController.addListener(_onJournalChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _moodProvider = context.read<MoodProvider>();

    if (_dynamicMessage == null) {
      final recService = context.read<MoodRecommendationService>();
      final moodType = widget.moodData.type;

      Future.wait([
        recService.getMotivationMessage(moodType),
        recService.getJournalPrompt(moodType),
        recService.getQuotes(moodType, count: 3),
        recService.getActivities(moodType, count: 3),
        recService.getMusicRecommendations(moodType, count: 3),
      ]).then((results) {
        if (mounted) {
          setState(() {
            _dynamicMessage = results[0] as String;
            _dynamicJournalPrompt = results[1] as String;
            _dynamicQuotes = results[2] as List<Map<String, String>>;
            _dynamicActivities = results[3] as List<Map<String, dynamic>>;
            _dynamicMusic = results[4] as List<Map<String, String>>;
          });
        }
      });
    }
  }

  void _onJournalChanged() {
    _debounce?.cancel();
    if (_journalController.text.trim().isNotEmpty) {
      setState(() => _saveStatus = 'Saving...');
      _debounce = Timer(const Duration(milliseconds: 600), _autoSaveNote);
    } else {
      setState(() => _saveStatus = '');
    }
  }

  void _autoSaveNote() {
    final moodProvider = context.read<MoodProvider>();
    final note = _journalController.text.trim();
    if (note.isEmpty) return;

    final entries = moodProvider.entries;
    final entry = entries.firstWhere(
      (e) => e.mood == widget.moodData.type && e.id != null,
      orElse: () => MoodEntry(moodType: '', date: DateTime.now()),
    );
    if (entry.id != null) {
      moodProvider.updateNoteById(entry.id!, note);
      if (mounted) {
        setState(() => _saveStatus = 'Saved ✓');
      }
    }
  }

  @override
  void dispose() {
    // Flush any pending auto-save
    _debounce?.cancel();
    _journalController.removeListener(_onJournalChanged);
    final note = _journalController.text.trim();
    if (note.isNotEmpty) {
      final entries = _moodProvider.entries;
      final entry = entries.firstWhere(
        (e) => e.mood == widget.moodData.type && e.id != null,
        orElse: () => MoodEntry(moodType: '', date: DateTime.now()),
      );
      if (entry.id != null) {
        _moodProvider.updateNoteById(entry.id!, note);
      }
    }
    _journalController.dispose();
    _masterController.dispose();
    _emojiController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _saveNote() {
    _debounce?.cancel();
    _autoSaveNote();
  }

  void _navigateToBreathing() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreathingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = widget.moodData;

    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar with mood gradient ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background from MoodThemeRepository
                  Container(
                    decoration: BoxDecoration(
                      gradient: MoodThemeRepository.instance.getGradient(
                        mood.type,
                        isDark: theme.brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  // Animated mood background overlay
                  MoodAnimatedBackground(
                    mood: mood.type,
                    accentColor: Colors.white.withValues(alpha: 0.3),
                  ),
                  // Content
                  SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      // Emoji in glowing circle — animated
                      AnimatedBuilder(
                        animation: _emojiController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _emojiFade.value,
                            child: Transform.scale(
                              scale: _emojiScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: SlideTransition(
                              position: _floatingAnimation,
                              child: Hero(
                                tag: 'emoji_${mood.name}',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    mood.emoji,
                                    style: const TextStyle(fontSize: 56),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mood.heroTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _dynamicMessage ?? mood.message,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),

          // ── Content Sections ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Activities Section ──
                  FadeTransition(
                    opacity: _activitiesFade,
                    child: SlideTransition(
                      position: _activitiesSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: mood.activitiesSectionTitle,
                            icon: Icons.checklist_rounded,
                            color: mood.color,
                          ),
                          const SizedBox(height: 16),
                          _buildActivities(theme, mood, _dynamicActivities),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Quotes Section ──
                  FadeTransition(
                    opacity: _quotesFade,
                    child: SlideTransition(
                      position: _quotesSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: mood.quotesSectionTitle,
                            icon: Icons.format_quote_rounded,
                            color: mood.color,
                          ),
                          const SizedBox(height: 16),
                          _buildQuotes(theme, mood, _dynamicQuotes),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Music Section ──
                  FadeTransition(
                    opacity: _musicFade,
                    child: SlideTransition(
                      position: _musicSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: mood.musicSectionTitle,
                            icon: Icons.headphones_rounded,
                            color: mood.color,
                          ),
                          const SizedBox(height: 16),
                          ...(_dynamicMusic ?? mood.musicSuggestions).map((song) => MusicTile(
                                title: song['title']!,
                                artist: song['artist']!,
                                accentColor: mood.color,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Journal Section ──
                  FadeTransition(
                    opacity: _journalFade,
                    child: SlideTransition(
                      position: _journalSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: mood.journalSectionTitle,
                            icon: Icons.edit_note_rounded,
                            color: mood.color,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: mood.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_note_rounded, color: mood.color, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _dynamicJournalPrompt ?? mood.journalPrompt,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: mood.color,
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
                              controller: _journalController,
                              maxLines: 4,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Write your thoughts here...',
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Auto-save status indicator
                          AnimatedOpacity(
                            opacity: _saveStatus.isNotEmpty ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                children: [
                                  if (_saveStatus == 'Saved ✓')
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 14,
                                      color: mood.color,
                                    )
                                  else
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: mood.color,
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _saveStatus,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: mood.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Save Note button (manual fallback)
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(
                              onPressed: _saveNote,
                              style: FilledButton.styleFrom(
                                backgroundColor: mood.color.withValues(alpha: 0.15),
                                foregroundColor: mood.color,
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
                                    style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Breathing CTA (only for moods that have it) ──
                  if (mood.showBreathingCTA)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [mood.color, mood.darkColor],
                            ),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.25),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                                spreadRadius: -8,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _navigateToBreathing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.air_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  mood.ctaLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Builds the Activities Section ──
  Widget _buildActivities(ThemeData theme, MoodData mood, List<Map<String, dynamic>>? dynamicActivities) {
    final acts = dynamicActivities ?? List.generate(mood.activities.length, (i) {
      return {
        "name": mood.activities[i],
        "desc": i < mood.activityDescriptions.length ? mood.activityDescriptions[i] : "",
        "icon": i < mood.activityIcons.length ? mood.activityIcons[i] : null,
      };
    });

    final hasDescriptions = acts.any((a) => a['desc'] != null && a['desc'].toString().isNotEmpty);
    final hasIcons = acts.any((a) => a['icon'] != null);

    // Sad mood: Chip-style pills layout
    if (mood.type == MoodType.sad) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(acts.length, (i) {
          final act = acts[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (i * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (act['icon'] != null)
                    Icon(act['icon'], color: mood.color, size: 20),
                  if (act['icon'] != null)
                    const SizedBox(width: 8),
                  Text(
                    act['name'],
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    // Bento card grid (with icons and descriptions)
    if (hasDescriptions && hasIcons) {
      return Column(
        children: List.generate(acts.length, (i) {
          final act = acts[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (i * 120)),
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: mood.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        act['icon'] ?? Icons.star_rounded,
                        color: mood.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (act['desc'] != null && act['desc'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                act['desc'],
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    }

    // Default: Simple list items with dot
    return Column(
      children: acts.asMap().entries.map((entry) {
        final idx = entry.key;
        final act = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (idx * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (act['icon'] != null) ...[
                    Icon(act['icon'], color: mood.color, size: 22),
                    const SizedBox(width: 12),
                  ] else ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: mood.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      act['name'],
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Builds the Quotes Section with text animation ──
  Widget _buildQuotes(ThemeData theme, MoodData mood, List<Map<String, String>>? dynamicQuotes) {
    final qs = dynamicQuotes ?? List.generate(mood.quotes.length, (i) {
      return {
        "quote": mood.quotes[i],
        "author": i < mood.quoteAuthors.length ? mood.quoteAuthors[i] : "Unknown",
      };
    });

    // Motivated: Large hero quote card
    if (mood.type == MoodType.motivated && qs.isNotEmpty) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final text = qs.first['quote']!;
          final author = qs.first['author']!;
          final charCount = (text.length * value).round();
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: mood.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: mood.color.withValues(alpha: 0.15),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -16,
                  right: -16,
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: mood.lightColor,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${text.substring(0, charCount)}"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: value > 0.9 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '— $author',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    // Relaxed: Gradient card style quote
    if (mood.type == MoodType.relaxed && qs.isNotEmpty) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final text = qs.first['quote']!;
          final author = qs.first['author']!;
          final charCount = (text.length * value).round();
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mood.color, mood.darkColor],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: mood.color.withValues(alpha: 0.15),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${text.substring(0, charCount)}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: value > 0.9 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '— $author',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Default: Standard blockquote cards with text animation
    return Column(
      children: List.generate(qs.length, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 700 + (i * 150)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final text = qs[i]['quote']!;
            final author = qs[i]['author']!;
            final charCount = (text.length * value).round();
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                        color: mood.color.withValues(alpha: 0.6), width: 3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          color: mood.color.withValues(alpha: 0.4),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '"${text.substring(0, charCount)}"',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedOpacity(
                      opacity: value > 0.85 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 36),
                        child: Text(
                          '— $author',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
