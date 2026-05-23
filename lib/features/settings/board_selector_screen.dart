import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/settings_provider.dart';
import '../../core/services/asset_service.dart';

class BoardSelectorScreen extends ConsumerStatefulWidget {
  const BoardSelectorScreen({super.key});

  @override
  ConsumerState<BoardSelectorScreen> createState() =>
      _BoardSelectorScreenState();
}

class _BoardSelectorScreenState extends ConsumerState<BoardSelectorScreen> {
  late String _selectedBoard;
  late String _selectedPieces;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedBoard = settings.boardTheme;
    _selectedPieces = settings.pieceSet;
  }

  Future<void> _saveAndApply() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateBoardTheme(_selectedBoard);
    await notifier.updatePieceSet(_selectedPieces);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings applied successfully'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetService = ref.read(assetServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Board & Pieces'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenH,
              right: AppSpacing.screenH,
              top: AppSpacing.screenV,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Board Themes', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: assetService.boardThemes.length,
                  itemBuilder: (context, i) {
                    final theme = assetService.boardThemes[i];
                    final isSelected = theme.id == _selectedBoard;
                    return _SelectionCard(
                      label: theme.name,
                      image: theme.file,
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedBoard = theme.id;
                        _hasChanges = true;
                      }),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Piece Sets', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: assetService.pieceSets.length,
                  itemBuilder: (context, i) {
                    final pieceSet = assetService.pieceSets[i];
                    final isSelected = pieceSet.id == _selectedPieces;
                    return _PieceSelectionCard(
                      label: pieceSet.name,
                      pieceId: pieceSet.id,
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedPieces = pieceSet.id;
                        _hasChanges = true;
                      }),
                    );
                  },
                ),
              ],
            ),
          ),

          // Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0),
                    AppColors.backgroundDeep,
                  ],
                ),
              ),
              child: ChtButton(
                label: 'Save & Apply',
                onPressed: _hasChanges ? _saveAndApply : null,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8)
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceSelectionCard extends StatelessWidget {
  const _PieceSelectionCard({
    required this.label,
    required this.pieceId,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String pieceId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryGlow : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pieces/$pieceId/wK.png',
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.grid_view_rounded),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
