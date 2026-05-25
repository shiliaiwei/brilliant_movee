import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../stoic_model.dart';
import 'stoic_visual_cover.dart';

class StoicCard extends StatelessWidget {
  final StoicLesson lesson;
  final VoidCallback? onTap;

  const StoicCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      cornerCut: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoicVisualCover(
            category: lesson.category,
            intensity: lesson.intensity,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanText(lesson.title).toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      _cleanText(lesson.content),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                        fontSize: 10,
                      ),
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

  String _cleanText(String text) {
    return text
        .replaceAll(
            RegExp(
                r'[#@\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}]',
                unicode: true),
            '')
        .trim();
  }
}
