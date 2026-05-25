import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cht_card.dart';
import '../stoic_model.dart';
import 'stoic_visual_cover.dart';

class StoicFlashcard extends StatelessWidget {
  final StoicLesson lesson;

  const StoicFlashcard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Visual Cover
          StoicVisualCover(
            category: lesson.category,
            intensity: lesson.intensity,
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title.toUpperCase(),
                    style: AppTextStyles.headline.copyWith(
                      letterSpacing: 2,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFormattedContent(lesson.content),
                  const SizedBox(height: 24),

                  // Directive Block
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
                              "DIRECTIVE",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormattedContent(String content) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');

    final List<String> metaLines = [];
    final List<String> bodyLines = [];

    for (var line in lines) {
      if (line.startsWith('[VISUAL]') ||
          line.startsWith('[GRAMMAR]') ||
          line.startsWith('[STRATEGY]') ||
          line.startsWith('[GRAPH]') ||
          line.startsWith('[DATA]')) {
        metaLines.add(line);
      } else {
        bodyLines.add(line);
      }
    }

    // Build Metadata Section
    if (metaLines.isNotEmpty) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: metaLines.map((meta) {
              IconData icon = Icons.info_outline_rounded;
              String label = "";
              String value = "";

              if (meta.startsWith('[VISUAL]')) {
                icon = Icons.visibility_rounded;
                label = "VISUAL";
                value = meta.replaceFirst('[VISUAL]', '').trim();
              } else if (meta.startsWith('[GRAMMAR]')) {
                icon = Icons.spellcheck_rounded;
                label = "GRAMMAR";
                value = meta.replaceFirst('[GRAMMAR]', '').trim();
              } else if (meta.startsWith('[STRATEGY]')) {
                icon = Icons.account_tree_rounded;
                label = "STRATEGY";
                value = meta.replaceFirst('[STRATEGY]', '').trim();
              } else if (meta.startsWith('[GRAPH]')) {
                icon = Icons.auto_graph_rounded;
                label = "DATA GRAPH";
                value = meta.replaceFirst('[GRAPH]', '').trim();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 12, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                          children: [
                            TextSpan(
                                text: "$label: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                            TextSpan(text: _cleanText(value)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }

    // Body Content
    if (bodyLines.isNotEmpty) {
      widgets.add(
        Text(
          _cleanText(bodyLines.join('\n')),
          textAlign: TextAlign.justify,
          style: AppTextStyles.body.copyWith(
            height: 1.8,
            fontSize: 14,
            color: AppColors.textPrimary.withValues(alpha: 0.9),
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return widgets;
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
