import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../tip_model.dart';
import 'tip_visual_cover.dart';

class TipDetailsSheet extends StatelessWidget {
  final Tip tip;
  final String languageCode;

  const TipDetailsSheet({
    super.key,
    required this.tip,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return ChtElevatedCard(
      padding: EdgeInsets.zero,
      cornerCut: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TipVisualCover(tip: tip),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.getTitle(languageCode).toUpperCase(),
                  style: AppTextStyles.headline.copyWith(
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tip.getExplanation(languageCode),
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
                      Text(
                        "PRACTICAL APPLICATION",
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Study this concept during your next analysis session. Recognition is the first step to mastery.",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
