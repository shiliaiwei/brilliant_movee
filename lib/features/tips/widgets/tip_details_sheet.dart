import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../tip_model.dart';
// Visual cover removed - details sheet simplified

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
