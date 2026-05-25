import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import 'tips_provider.dart';
import 'tip_model.dart';
import 'widgets/tip_card.dart';
import 'widgets/tip_details_sheet.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  TipCategory _selectedCategory = TipCategory.openingNames;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(languageProvider);
    final state = ref.watch(tipsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(
          "TIPS & OPENINGS",
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
          // Filter Bar
          _buildCategoryFilter(),

          // Content Grid
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.errorMessage != null
                    ? Center(child: Text(state.errorMessage!))
                    : _buildContentGrid(state, languageCode),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TipCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getCategoryLabel(category),
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
              onSelected: (_) => setState(() => _selectedCategory = category),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryLabel(TipCategory category) {
    switch (category) {
      case TipCategory.opening:
        return 'CONCEPTS';
      case TipCategory.middlegame:
        return 'MIDDLEGAME';
      case TipCategory.endgame:
        return 'ENDGAME';
      case TipCategory.tactics:
        return 'TACTICS';
      case TipCategory.mindset:
        return 'MINDSET';
      case TipCategory.stoic:
        return 'STOIC';
      case TipCategory.openingNames:
        return 'OPENINGS';
    }
  }

  Widget _buildContentGrid(TipsState state, String languageCode) {
    final filteredTips =
        state.allTips.where((t) => t.category == _selectedCategory).toList();

    if (filteredTips.isEmpty) {
      return const Center(
        child: Opacity(
          opacity: 0.5,
          child: Text("NO DATA IN THIS SECTOR"),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredTips.length,
      itemBuilder: (context, index) {
        final tip = filteredTips[index];
        return TipCard(
          tip: tip,
          languageCode: languageCode,
          onTap: () => _showDetails(tip, languageCode),
        );
      },
    );
  }

  void _showDetails(Tip tip, String languageCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TipDetailsSheet(
        tip: tip,
        languageCode: languageCode,
      ),
    );
  }
}
