import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (password.isEmpty) return const SizedBox.shrink();

    final checks = _evaluatePassword(password);
    final score = checks.values.where((v) => v).length;
    final strength = _getStrength(score);
    final color = _getColor(score);
    final progress = score / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Animated progress bar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                color: theme.colorScheme.surfaceContainerHigh,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Strength label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            strength,
            key: ValueKey(strength),
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Requirement checklist
        _CheckItem(
          label: 'At least 8 characters',
          passed: checks['length']!,
          theme: theme,
        ),
        _CheckItem(
          label: 'One uppercase letter',
          passed: checks['uppercase']!,
          theme: theme,
        ),
        _CheckItem(
          label: 'One lowercase letter',
          passed: checks['lowercase']!,
          theme: theme,
        ),
        _CheckItem(
          label: 'One number',
          passed: checks['number']!,
          theme: theme,
        ),
        _CheckItem(
          label: 'One special character',
          passed: checks['special']!,
          theme: theme,
        ),
      ],
    );
  }

  Map<String, bool> _evaluatePassword(String password) {
    return {
      'length': password.length >= 8,
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'lowercase': password.contains(RegExp(r'[a-z]')),
      'number': password.contains(RegExp(r'[0-9]')),
      'special': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]')),
    };
  }

  String _getStrength(int score) {
    switch (score) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Color _getColor(int score) {
    switch (score) {
      case 0:
        return const Color(0xFFD32F2F); // Red
      case 1:
        return const Color(0xFFD32F2F); // Red
      case 2:
        return const Color(0xFFF57C00); // Orange
      case 3:
        return const Color(0xFFFBC02D); // Yellow
      case 4:
        return const Color(0xFF0288D1); // Blue
      case 5:
        return const Color(0xFF388E3C); // Green
      default:
        return const Color(0xFFD32F2F);
    }
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool passed;
  final ThemeData theme;

  const _CheckItem({
    required this.label,
    required this.passed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              passed
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              key: ValueKey(passed),
              size: 16,
              color: passed
                  ? const Color(0xFF388E3C)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: passed
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
