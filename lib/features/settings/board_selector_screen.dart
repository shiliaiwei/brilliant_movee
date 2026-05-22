import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/storage_service.dart';
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
    final storage = ref.read(storageServiceProvider);
    _selectedBoard = storage.boardTheme;
    _selectedPieces = storage.pieceSet;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    if (!mounted) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        title: Text('Discard Changes?', style: AppTextStyles.title),
        content: Text(
          'You have unsaved changes. Discard them?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Editing',
                style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveAndApply() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setBoardTheme(_selectedBoard);
    await storage.setPieceSet(_selectedPieces);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final assetService = ref.read(assetServiceProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            if (context.canPop()) context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        appBar: AppBar(
          title: const Text('Board & Pieces'),
          backgroundColor: AppColors.backgroundDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                if (context.canPop()) context.pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenH,
                right: AppSpacing.screenH,
                top: AppSpacing.screenV,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Board themes
                  Text('Board Theme', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: assetService.boardThemes.length,
                    itemBuilder: (context, i) {
                      final theme = assetService.boardThemes[i];
                      final isSelected = theme.id == _selectedBoard;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedBoard = theme.id;
                          _hasChanges = true;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryBorder,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Stack(
                              children: [
                                Image.asset(
                                  theme.file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.backgroundElevated,
                                    child: const Icon(Icons.grid_on_rounded,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: AppColors.scrim,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      theme.name,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: AppColors.backgroundDeep,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Piece sets
                  Text('Piece Set', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: assetService.pieceSets.length,
                    itemBuilder: (context, i) {
                      final pieceSet = assetService.pieceSets[i];
                      final isSelected = pieceSet.id == _selectedPieces;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedPieces = pieceSet.id;
                          _hasChanges = true;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/pieces/${pieceSet.id}/wK.png',
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.king_bed_rounded,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                pieceSet.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Save button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  MediaQuery.of(context).padding.bottom + AppSpacing.md,
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
                  onPressed: _saveAndApply,
                  icon: Icons.check_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
