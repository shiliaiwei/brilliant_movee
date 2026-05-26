import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../stoic_model.dart';
import 'stoic_visual_cover.dart';

class StoicDetailSheet extends StatelessWidget {
  final StoicLesson lesson;

  const StoicDetailSheet({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Cover
                  StoicVisualCover(
                    category: lesson.category,
                    intensity: lesson.intensity,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Time
                        Row(
                          children: [
                            Text(
                              lesson.category.label,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text("•",
                                style: TextStyle(color: Colors.white24)),
                            const SizedBox(width: 8),
                            Text(
                              _estimateReadTime(),
                              style: AppTextStyles.badge
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            const Spacer(),
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
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          lesson.title.toUpperCase(),
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 26,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Render Sections
                        ...lesson.sections
                            .map((section) => _buildSection(section)),

                        const SizedBox(height: 16),

                        // System Directive Block (Premium Feel)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt,
                                      size: 20, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Text(
                                    "SYSTEM DIRECTIVE",
                                    style: AppTextStyles.monoSmall.copyWith(
                                      color: AppColors.primary,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                lesson.directive,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 17,
                                  height: 1.6,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(StoicSection section) {
    IconData icon;
    Color color = AppColors.primary;

    switch (section.type) {
      case 'visual':
        icon = Icons.visibility_rounded;
        break;
      case 'grammar':
        icon = Icons.spellcheck_rounded;
        break;
      case 'strategy':
        icon = Icons.account_tree_rounded;
        break;
      case 'graph':
        icon = Icons.auto_graph_rounded;
        break;
      case 'data':
        icon = Icons.analytics_rounded;
        break;
      default:
        icon = Icons.notes_rounded;
        color = AppColors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Text(
                section.title.toUpperCase(),
                style: AppTextStyles.monoSmall.copyWith(
                  color: color.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.body,
            style: AppTextStyles.body.copyWith(
              height: 1.7,
              fontSize: 15,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
            ),
          ),
          if (section.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.bulletPoints.map((bp) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(color: AppColors.primary)),
                      Expanded(
                        child: Text(
                          bp,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _estimateReadTime() {
    int wordCount = 0;
    wordCount += lesson.title.split(' ').length;
    wordCount += lesson.directive.split(' ').length;
    for (var section in lesson.sections) {
      wordCount += section.body.split(' ').length;
      for (var bp in section.bulletPoints) {
        wordCount += bp.split(' ').length;
      }
    }

    final minutes = (wordCount / 200).ceil();
    return '$minutes min read';
  }
}
