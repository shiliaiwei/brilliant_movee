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
                                    return StoicFlashcard(lesson: lesson);
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
