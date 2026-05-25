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
            TipVisualCover(tip: tip, isDetailed: true),
            Flexible(
              child: SingleChildScrollView(
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
                          Row(
                            children: [
                              const Icon(Icons.psychology_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                "STRATEGIC ADVICE",
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Master the key squares and positional goals of this line. Recognition leads to dominance.",
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
            ),
          ],
        ),
      ),
    );
  }
}
