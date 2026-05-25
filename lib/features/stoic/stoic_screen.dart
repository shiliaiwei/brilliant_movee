import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'stoic_provider.dart';
import 'stoic_model.dart';
import 'widgets/stoic_card.dart';
import 'widgets/stoic_details_sheet.dart';

class StoicScreen extends ConsumerStatefulWidget {
  const StoicScreen({super.key});

  @override
  ConsumerState<StoicScreen> createState() => _StoicScreenState();
}

class _StoicScreenState extends ConsumerState<StoicScreen> {
  final ScrollController _filterController = ScrollController();
  final Map<StoicCategory, GlobalKey> _categoryKeys = {
    for (var cat in StoicCategory.values) cat: GlobalKey(),
  };

  @override
  void dispose() {
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
          "STOIC",
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

          // Status and Visual Example Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.auto_graph_rounded,
                    size: 12, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "VISUAL DATA ENGINE ACTIVE",
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  "${state.filteredLessons.length} ENTRIES",
                  style: AppTextStyles.monoSmall.copyWith(fontSize: 8),
                ),
              ],
            ),
          ),

          // Content Grid
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: state.filteredLessons.length,
                        itemBuilder: (context, index) {
                          final lesson = state.filteredLessons[index];
                          return StoicCard(
                            lesson: lesson,
                            onTap: () => _showDetails(context, lesson),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, StoicLesson lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StoicDetailsSheet(lesson: lesson),
    );
  }
}
