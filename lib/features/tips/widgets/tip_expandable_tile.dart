import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../tip_model.dart';
import 'tip_visual_cover.dart';

class TipExpandableTile extends ConsumerWidget {
  final Tip tip;
  final bool isExpanded;
  final VoidCallback onToggle;

  const TipExpandableTile({
    super.key,
    required this.tip,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(languageProvider);
    final title = tip.getTitle(languageCode);
    final explanation = tip.getExplanation(languageCode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpanded ? AppColors.primary : AppColors.divider,
          width: isExpanded ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header (Always Visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    tip.category == TipCategory.openingNames
                        ? Icons.grid_goldenratio_rounded
                        : Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: isExpanded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: isExpanded ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Drop Down Style)
          if (isExpanded) ...[
            TipVisualCover(tip: tip, isDetailed: true),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explanation,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundDeep,
                      border: Border(
                        left: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    child: const Text(
                      "STRATEGIC ADVICE: Focus on key development and center control.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
