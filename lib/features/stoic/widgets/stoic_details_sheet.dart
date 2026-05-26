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
                    // Render full plain content as a single readable block
                    Text(
                      _cleanText(lesson.content),
                      textAlign: TextAlign.left,
                      style: AppTextStyles.body.copyWith(
                        height: 1.8,
                        fontSize: 14,
                        color: AppColors.textPrimary.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 24),
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
    // remove non-ascii (emoji) by keeping only runes < 128 and trim
    final asciiOnly = String.fromCharCodes(text.runes.where((r) => r < 128));
    return asciiOnly.replaceAll('#', '').replaceAll('@', '').trim();
  }
}
