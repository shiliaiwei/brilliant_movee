import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'tips_provider.dart';
import 'tip_model.dart';
import 'widgets/tip_expandable_tile.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  TipCategory _selectedCategory = TipCategory.openingNames;
  int? _expandedId;

  final ScrollController _filterController = ScrollController();
  final Map<TipCategory, GlobalKey> _categoryKeys = {
    for (var cat in TipCategory.values) cat: GlobalKey(),
  };

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _scrollToCategory(TipCategory category) {
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
          // Filter Bar with auto-centering
          _buildCategoryFilter(),

          // Content List (Drop Down Style)
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.errorMessage != null
                    ? Center(child: Text(state.errorMessage!))
                    : _buildContentList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final orderedCategories = [
      TipCategory.openingNames,
      TipCategory.opening,
      TipCategory.middlegame,
      TipCategory.endgame,
      TipCategory.tactics,
      TipCategory.mindset,
      TipCategory.stoic,
    ];

    return SingleChildScrollView(
      controller: _filterController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: orderedCategories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            key: _categoryKeys[category],
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
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                  _expandedId = null; // Close any open items when switching
                });
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

  Widget _buildContentList(TipsState state) {
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

    return RefreshIndicator(
      onRefresh: () async => ref.read(tipsProvider.notifier).reload(),
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundSurface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredTips.length,
        itemBuilder: (context, index) {
          final tip = filteredTips[index];
          return TipExpandableTile(
            tip: tip,
            isExpanded: _expandedId == tip.id,
            onToggle: () {
              setState(() {
                _expandedId = (_expandedId == tip.id) ? null : tip.id;
              });
            },
          );
        },
      ),
    );
  }
}
