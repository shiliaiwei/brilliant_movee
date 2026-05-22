import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import '../../engine/move_classifier.dart';

/// Color-coded move quality badge (pill shape, monospace font).
class ChtMoveBadge extends StatelessWidget {
  const ChtMoveBadge({
    super.key,
    required this.quality,
    this.showGlow = false,
    this.compact = false,
  });

  final MoveQuality quality;
  final bool showGlow;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(quality);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border:
            Border.all(color: config.color.withValues(alpha: 0.6), width: 1),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        compact ? config.symbol : config.label,
        style: AppTextStyles.badge.copyWith(
          color: config.color,
          fontSize: compact ? 9 : 10,
        ),
      ),
    );
  }

  _BadgeConfig _badgeConfig(MoveQuality q) {
    switch (q) {
      case MoveQuality.brilliant:
        return _BadgeConfig(AppColors.brilliant, '!! BRILLIANT', '!!');
      case MoveQuality.great:
        return _BadgeConfig(AppColors.great, '! GREAT', '!');
      case MoveQuality.best:
        return _BadgeConfig(AppColors.primary, 'BEST', '★');
      case MoveQuality.good:
        return _BadgeConfig(AppColors.good, 'GOOD', '✓');
      case MoveQuality.book:
        return _BadgeConfig(AppColors.book, 'BOOK', '📖');
      case MoveQuality.inaccuracy:
        return _BadgeConfig(AppColors.inaccuracy, 'INACCURACY', '?!');
      case MoveQuality.mistake:
        return _BadgeConfig(AppColors.mistake, 'MISTAKE', '?');
      case MoveQuality.blunder:
        return _BadgeConfig(AppColors.blunder, 'BLUNDER', '??');
      case MoveQuality.miss:
        return _BadgeConfig(AppColors.miss, 'MISS', '✗');
      case MoveQuality.forced:
        return _BadgeConfig(AppColors.textSecondary, 'FORCED', '→');
    }
  }
}

class _BadgeConfig {
  const _BadgeConfig(this.color, this.label, this.symbol);
  final Color color;
  final String label;
  final String symbol;
}

/// Generic colored badge chip.
class ChtBadge extends StatelessWidget {
  const ChtBadge({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

/// Result badge: WIN / LOSS / DRAW
class ChtResultBadge extends StatelessWidget {
  const ChtResultBadge({super.key, required this.result});

  final String result; // '1-0', '0-1', '1/2-1/2'

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (result) {
      '1-0' => ('WIN', AppColors.win),
      '0-1' => ('LOSS', AppColors.loss),
      _ => ('DRAW', AppColors.draw),
    };
    return ChtBadge(label: label, color: color);
  }
}

/// Rating category badge - Premium White Redesign
class ChtRatingBadge extends StatelessWidget {
  const ChtRatingBadge({
    super.key,
    required this.category,
    required this.rating,
  });

  final String category;
  final int rating;

  @override
  Widget build(BuildContext context) {
    if (rating == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.toUpperCase(),
            style: AppTextStyles.badge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$rating',
            style: AppTextStyles.monoLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
