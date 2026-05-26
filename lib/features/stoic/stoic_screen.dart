import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'stoic_provider.dart';
import 'stoic_model.dart';
import 'widgets/stoic_flashcard.dart';

class StoicScreen extends ConsumerStatefulWidget {
  const StoicScreen({super.key});

  @override
  ConsumerState<StoicScreen> createState() => _StoicScreenState();
}

// Full-reading dialog that displays lessons in a PageView so the user
// can read one-by-one like pages of a paper. Includes prev/next controls
// and a close button. Kept inside this file for simplicity.
class StoicReaderDialog extends StatefulWidget {
  final List<StoicLesson> lessons;
  final int initialIndex;

  const StoicReaderDialog(
      {super.key, required this.lessons, this.initialIndex = 0});

  @override
  State<StoicReaderDialog> createState() => _StoicReaderDialogState();
}

class _StoicReaderDialogState extends State<StoicReaderDialog> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.lessons.length) return;
    _controller.animateToPage(newIndex,
        duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      backgroundColor: AppColors.backgroundDeep,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            // Top bar with close and position
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_index + 1} / ${widget.lessons.length}',
                      style: AppTextStyles.monoSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // spacer for symmetry
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.lessons.length,
                onPageChanged: (p) => setState(() => _index = p),
                itemBuilder: (context, i) {
                  final lesson = widget.lessons[i];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Paper-like card
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSurface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title.toUpperCase(),
                                  style: AppTextStyles.headline.copyWith(
                                      fontSize: 22,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${lesson.category.label} • ${_estimateReadTime(lesson.content)}',
                                  style: AppTextStyles.badge
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 20),
                                ..._buildFormattedContent(lesson.content),
                                const SizedBox(height: 32),

                                // Full Directive Block
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundDeep,
                                    borderRadius: BorderRadius.circular(12),
                                    border: const Border(
                                      left: BorderSide(
                                          color: AppColors.primary, width: 4),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.psychology,
                                              size: 18,
                                              color: AppColors.primary),
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
                                          color: AppColors.primary
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // bottom controls: prev / next
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _index > 0 ? () => _jumpTo(_index - 1) : null,
                    icon: Icon(Icons.chevron_left,
                        color: _index > 0
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                  Text(
                    widget.lessons[_index].title,
                    style: AppTextStyles.monoSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    onPressed: _index < widget.lessons.length - 1
                        ? () => _jumpTo(_index + 1)
                        : null,
                    icon: Icon(Icons.chevron_right,
                        color: _index < widget.lessons.length - 1
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return '${minutes} min read';
  }
}

class _StoicScreenState extends ConsumerState<StoicScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.96);
  final ScrollController _filterController = ScrollController();
  final Map<StoicCategory, GlobalKey> _categoryKeys = {
    for (var cat in StoicCategory.values) cat: GlobalKey(),
  };
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (!_pageController.hasClients) return;
      final nextPage = (_pageController.page ?? 0).round();
      if (nextPage != _currentPage && mounted) {
        setState(() => _currentPage = nextPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _scrollToCategory(StoicCategory category) {
    final key = _categoryKeys[category];
    if (key == null) return;

    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stoicProvider);
    final notifier = ref.read(stoicProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(
          "STOIC WISDOM",
          style: AppTextStyles.monoLarge.copyWith(
            letterSpacing: 4,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips with auto-centering
          SingleChildScrollView(
            controller: _filterController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: StoicCategory.values.map((category) {
                final isSelected = state.selectedCategory == category;
                return Padding(
                  key: _categoryKeys[category],
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      category.label,
                      style: AppTextStyles.badge.copyWith(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.backgroundDeep
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.backgroundSurface,
                    onSelected: (_) {
                      notifier.selectCategory(category);
                      _scrollToCategory(category);
                      setState(() => _currentPage = 0);
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),

          // Reading-first content area
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : state.filteredLessons.isEmpty
                        ? const Center(child: Text("NO DATA IN THIS SECTOR"))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 860),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: state.filteredLessons.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final lesson = state.filteredLessons[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // open full-reading dialog that allows
                                        // navigating lessons one-by-one like paper
                                        showDialog(
                                          context: context,
                                          builder: (_) => StoicReaderDialog(
                                            lessons: state.filteredLessons,
                                            initialIndex: index,
                                          ),
                                        );
                                      },
                                      child: StoicFlashcard(lesson: lesson),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
          ),

          // Simplified footer: only show page counter (removed prev/next buttons)
          if (state.filteredLessons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_currentPage + 1} / ${state.filteredLessons.length}",
                    style: AppTextStyles.monoSmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
