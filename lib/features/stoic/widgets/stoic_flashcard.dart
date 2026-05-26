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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Cover
          StoicVisualCover(
            category: lesson.category,
            intensity: lesson.intensity,
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              physics:
                  const NeverScrollableScrollPhysics(), // Card is teaser only
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title.toUpperCase(),
                          style: AppTextStyles.headline.copyWith(
                            letterSpacing: 2,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (lesson.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTextStyles.badge.copyWith(
                                color: AppColors.backgroundDeep,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewContent(),
                  const SizedBox(height: 20),

                  // Directive Block Preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDeep.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        left: BorderSide(color: AppColors.primary, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              "DIRECTIVE",
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lesson.directive,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer hint
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'TAP TO STUDY',
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.primary.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    // Find first body section or fallback to first section or content
    final bodySection = lesson.sections.firstWhere((s) => s.type == 'body',
        orElse: () => lesson.sections.isNotEmpty
            ? lesson.sections.first
            : StoicSection(title: '', body: lesson.content));

    return Text(
      bodySection.body,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body.copyWith(
        height: 1.6,
        fontSize: 14,
        color: AppColors.textPrimary.withValues(alpha: 0.9),
      ),
    );
  }
}
