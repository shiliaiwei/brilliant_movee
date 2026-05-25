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
  final PageController _pageController = PageController(viewportFraction: 0.92);
  final ScrollController _filterController = ScrollController();
  final Map<StoicCategory, GlobalKey> _categoryKeys = {
    for (var cat in StoicCategory.values) cat: GlobalKey(),
  };

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

          // Content Pager (Short Realistic Flashcard style)
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : state.filteredLessons.isEmpty
                        ? const Center(child: Text("NO DATA IN THIS SECTOR"))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    540, // Constrained height for Handheld Card feel
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: state.filteredLessons.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final lesson = state.filteredLessons[index];
                                    return AnimatedBuilder(
                                      animation: _pageController,
                                      builder: (context, child) {
                                        double value = 1.0;
                                        if (_pageController
                                            .position.hasContentDimensions) {
                                          value = _pageController.page! - index;
                                          // Scale and Opacity effect for realistic depth
                                          value = (1 - (value.abs() * 0.15))
                                              .clamp(0.0, 1.0);
                                        }
                                        return Center(
                                          child: Transform.scale(
                                            scale: value,
                                            child: Opacity(
                                              opacity: value,
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                      child: StoicFlashcard(lesson: lesson),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
          ),

          // Navigation Controls
          if (state.filteredLessons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavButton(
                    icon: Icons.keyboard_arrow_left_rounded,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                  const SizedBox(width: 40),
                  ValueListenableBuilder<double>(
                    valueListenable: ValueNotifier(_pageController.hasClients
                        ? _pageController.page ?? 0
                        : 0),
                    builder: (context, page, _) {
                      return Text(
                        "${(page.round() + 1)} / ${state.filteredLessons.length}",
                        style: AppTextStyles.monoSmall,
                      );
                    },
                  ),
                  const SizedBox(width: 40),
                  _NavButton(
                    icon: Icons.keyboard_arrow_right_rounded,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
