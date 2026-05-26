import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../stoic_model.dart';
import 'stoic_visual_cover.dart';

class StoicFlashcard extends StatelessWidget {
  final StoicLesson lesson;

  const StoicFlashcard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final excerpt = _excerpt(lesson.content, 220);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual cover (image + subtle overlay)
          StoicVisualCover(
              category: lesson.category, intensity: lesson.intensity),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: AppTextStyles.badge.copyWith(
                            color: AppColors.backgroundDeep, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  excerpt,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary.withValues(alpha: 0.95),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tap to open',
                    style: AppTextStyles.badge
                        .copyWith(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _excerpt(String content, int maxChars) {
    final cleaned = _cleanText(content).replaceAll('\n', ' ');
    if (cleaned.length <= maxChars) return cleaned;
    return '${cleaned.substring(0, maxChars).trim()}...';
  }

  String _cleanText(String text) {
    // remove non-ascii (emoji) by keeping only runes < 128, then strip simple symbols
    final asciiOnly = String.fromCharCodes(text.runes.where((r) => r < 128));
    final cleaned = asciiOnly.replaceAll('#', '').replaceAll('@', '').trim();
    return cleaned;
  }
}
