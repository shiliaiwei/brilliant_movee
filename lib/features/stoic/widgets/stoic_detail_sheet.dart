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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title.toUpperCase(),
                                style: AppTextStyles.headline.copyWith(
                                    fontSize: 22,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
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
                        const SizedBox(height: 8),
                        Text(
                          '${lesson.category.label} • ${_estimateReadTime(lesson.content)}',
                          style: AppTextStyles.badge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),

                        // Formatted Content
                        ..._buildFormattedContent(lesson.content),
                        const SizedBox(height: 32),

                        // System Directive Block
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSurface
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              left: BorderSide(
                                  color: AppColors.primary, width: 4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Text(
                                    "SYSTEM DIRECTIVE",
                                    style: AppTextStyles.badge.copyWith(
                                      color: AppColors.primary,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _clean(lesson.directive),
                                style: AppTextStyles.body.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  height: 1.5,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
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
              } else if (meta.startsWith('[DATA]')) {
                icon = Icons.analytics_rounded;
                label = "DATA";
                value = meta.replaceFirst('[DATA]', '').trim();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 14, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(fontSize: 12),
                          children: [
                            TextSpan(
                                text: "$label: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                            TextSpan(text: _clean(value)),
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
      widgets.add(const SizedBox(height: 24));
    }

    // Body Content
    if (bodyLines.isNotEmpty) {
      widgets.add(
        Text(
          _clean(bodyLines.join('\n')),
          textAlign: TextAlign.justify,
          style: AppTextStyles.body.copyWith(
            height: 1.8,
            fontSize: 15,
            color: AppColors.textPrimary.withValues(alpha: 0.95),
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    return widgets;
  }

  String _clean(String text) {
    final asciiOnly = String.fromCharCodes(text.runes.where((r) => r < 128));
    return asciiOnly.replaceAll(RegExp(r"\[.*?\]"), '').trim();
  }

  String _estimateReadTime(String content) {
    final words =
        content.split(RegExp(r"\s+")).where((s) => s.isNotEmpty).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }
}
