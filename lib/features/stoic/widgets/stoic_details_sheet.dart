import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../stoic_model.dart';
import 'stoic_visual_cover.dart';

class StoicDetailsSheet extends StatelessWidget {
  final StoicLesson lesson;

  const StoicDetailsSheet({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: ChtElevatedCard(
        padding: EdgeInsets.zero,
        cornerCut: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StoicVisualCover(
              category: lesson.category,
              intensity: lesson.intensity,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanText(lesson.title).toUpperCase(),
                      style: AppTextStyles.headline.copyWith(
                        letterSpacing: 2,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _cleanText(lesson.content),
                      style: AppTextStyles.body.copyWith(
                        height: 1.6,
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundDeep,
                        border: Border(
                          left: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                "WISDOM",
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cleanText(lesson.directive),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanText(String text) {
    // Remove symbols and emojis as requested
    return text
        .replaceAll(
            RegExp(
                r'[#@\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}]',
                unicode: true),
            '')
        .trim();
  }
}
