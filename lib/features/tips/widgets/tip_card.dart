import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../tip_model.dart';
import 'tip_visual_cover.dart';

class TipCard extends StatelessWidget {
  final Tip tip;
  final String languageCode;
  final VoidCallback? onTap;

  const TipCard({
    super.key,
    required this.tip,
    required this.languageCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      cornerCut: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TipVisualCover(tip: tip),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.getTitle(languageCode).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip.getExplanation(languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
