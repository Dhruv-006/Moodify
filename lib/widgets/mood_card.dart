import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_model.dart';
import '../providers/mood_theme_provider.dart';
import '../core/theme/mood_animations.dart';
import '../core/theme/mood_theme_repository.dart';

class MoodCard extends StatefulWidget {
  final MoodData moodData;
  final VoidCallback onTap;

  const MoodCard({
    super.key,
    required this.moodData,
    required this.onTap,
  });

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final moodTheme = context.watch<MoodThemeProvider>();

    // Check if this card's mood is the currently active mood
    final isActiveMood = moodTheme.activeMood == widget.moodData.type;
    final animation = MoodThemeRepository.instance.getAnimation(widget.moodData.type);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: _buildCardContent(theme, isDark, isActiveMood, animation),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    ThemeData theme, bool isDark, bool isActiveMood, moodAnimation,
  ) {
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        // Active mood gets a subtle accent border glow
        border: isActiveMood
            ? Border.all(
                color: widget.moodData.color.withValues(alpha: 0.6),
                width: 1.5,
              )
            : Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
                width: 1,
              ),
        boxShadow: [
          // Base shadow to float above background
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          // Glow effect
          if (isActiveMood || _isHovered)
            BoxShadow(
              color: widget.moodData.color.withValues(alpha: isActiveMood ? 0.3 : 0.15),
              blurRadius: isActiveMood ? 40 : 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient overlay on hover or active
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: (_isHovered || isActiveMood) ? 1.0 : 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.moodData.lightColor.withValues(
                      alpha: isActiveMood ? 0.5 : 0.2,
                    ),
                    widget.moodData.color.withValues(
                      alpha: isActiveMood ? 0.2 : 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'emoji_${widget.moodData.name}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      widget.moodData.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.moodData.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isActiveMood ? widget.moodData.color : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.moodData.description
                      .replaceAll('User is feeling ', '')
                      .replaceAll('User feels ', '')
                      .replaceAll('User wants ', '')
                      .replaceAll('User ', ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap the active mood card in a subtle animation
    if (isActiveMood) {
      card = MoodAnimatedContainer(
        animation: moodAnimation,
        duration: const Duration(milliseconds: 2500),
        child: card,
      );
    }

    return card;
  }
}
