import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/widgets/cht_badge.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/eval_bar.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/responsive.dart';
import '../../engine/move_classifier.dart';
import '../../engine/pgn_parser.dart';
import 'board/chess_board_widget.dart';
import 'analysis/review_notifier.dart';
import 'celebrate/celebrate_overlay.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.gameId, required this.pgn});

  final String gameId;
  final String pgn;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _showCelebrate = false;
  bool _celebrateShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadGame(widget.pgn);
    });
  }

  void _checkGameEnd(ReviewState state) {
    if (_celebrateShown) return;
    if (state.isAtEnd && state.game != null) {
      _celebrateShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showCelebrate = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);
    final storage = ref.read(storageServiceProvider);

    // Check for game end
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGameEnd(state));

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Game Review'),
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Flip board button
          IconButton(
            icon: const Icon(Icons.flip_rounded),
            onPressed: () {/* flip board */},
            tooltip: 'Flip Board',
          ),
          // Analysis progress indicator
          if (state.isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: state.analysisProgress,
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : state.error != null
              ? ChtErrorState(
                  title: 'Failed to load game',
                  description: state.error!,
                  onRetry: () =>
                      ref.read(reviewProvider.notifier).loadGame(widget.pgn),
                )
              : Stack(
                  children: [
                    context.isWide
                        ? _WideReviewBody(state: state, storage: storage)
                        : _ReviewBody(state: state, storage: storage),
                    if (_showCelebrate)
                      CelebrateOverlay(
                        result: state.game?.result ?? '*',
                        username: storage.connectedUsername ?? '',
                        whiteUsername: state.game?.white ?? '',
                        analysisData: null,
                        onDismiss: () =>
                            setState(() => _showCelebrate = false),
                      ),
                  ],
                ),
    );
  }
}

class _ReviewBody extends ConsumerWidget {
  const _ReviewBody({required this.state, required this.storage});

  final ReviewState state;
  final StorageService storage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = state.currentBoardState;
    final currentClassification = state.classificationAt(state.currentPlyIndex);

    // Current eval from analysis
    final evalCp = currentClassification?.evalAfter ?? 0.0;

    return Column(
      children: [
        // Board + eval bar
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                // Eval bar
                AnimatedEvalBar(
                  evalCp: evalCp,
                  height: double.infinity,
                  width: 18,
                ),
                const SizedBox(width: AppSpacing.sm),

                // Chess board
                Expanded(
                  child: boardState != null
                      ? ChessBoardWidget(
                          boardState: boardState,
                          pieceSetId: storage.pieceSet,
                          boardThemeId: storage.boardTheme,
                          showCoordinates: storage.showCoordinates,
                          highlightLastMove: storage.highlightLastMove,
                        )
                      : const Center(
                          child: Icon(
                            Icons.grid_on_rounded,
                            color: AppColors.textSecondary,
                            size: 64,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        // Navigation controls
        _NavigationControls(state: state),

        // Move notation strip
        _MoveNotationStrip(state: state),

        // Analysis panel
        Expanded(
          flex: 3,
          child: _AnalysisPanel(
            state: state,
            classification: currentClassification,
          ),
        ),
      ],
    );
  }
}

class _NavigationControls extends ConsumerWidget {
  const _NavigationControls({required this.state});

  final ReviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reviewProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.first_page_rounded,
            onPressed: state.isAtStart ? null : notifier.goToStart,
            tooltip: 'First move',
          ),
          const SizedBox(width: AppSpacing.md),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: state.isAtStart ? null : notifier.goBack,
            tooltip: 'Previous move',
          ),
          const SizedBox(width: AppSpacing.md),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: state.isAtEnd ? null : notifier.goForward,
            tooltip: 'Next move',
          ),
          const SizedBox(width: AppSpacing.md),
          _NavButton(
            icon: Icons.last_page_rounded,
            onPressed: state.isAtEnd ? null : notifier.goToEnd,
            tooltip: 'Last move',
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveNotationStrip extends ConsumerWidget {
  const _MoveNotationStrip({required this.state});

  final ReviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.game == null) return const SizedBox.shrink();

    final moves = state.game!.moves;
    final scrollController = ScrollController();

    return SizedBox(
      height: 44,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: moves.length,
        itemBuilder: (context, i) {
          final move = moves[i];
          final plyIndex = i + 1;
          final isActive = plyIndex == state.currentPlyIndex;
          final classification = state.classificationAt(plyIndex);

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: _MoveChip(
              move: move,
              plyIndex: plyIndex,
              isActive: isActive,
              classification: classification,
              onTap: () =>
                  ref.read(reviewProvider.notifier).goToPly(plyIndex),
            ),
          );
        },
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.move,
    required this.plyIndex,
    required this.isActive,
    required this.classification,
    required this.onTap,
  });

  final PgnMove move;
  final int plyIndex;
  final bool isActive;
  final MoveClassification? classification;
  final VoidCallback onTap;

  Color get _qualityDotColor {
    if (classification == null) return Colors.transparent;
    return switch (classification!.quality) {
      MoveQuality.brilliant => AppColors.brilliant,
      MoveQuality.great => AppColors.great,
      MoveQuality.best => AppColors.primary,
      MoveQuality.good => AppColors.good,
      MoveQuality.book => AppColors.book,
      MoveQuality.inaccuracy => AppColors.inaccuracy,
      MoveQuality.mistake => AppColors.mistake,
      MoveQuality.blunder => AppColors.blunder,
      MoveQuality.miss => AppColors.miss,
      MoveQuality.forced => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGlow : AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.primaryBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (move.isWhite)
              Text(
                '${move.moveNumber}. ',
                style: AppTextStyles.monoSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            Text(
              move.san,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (classification != null) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _qualityDotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalysisPanel extends ConsumerWidget {
  const _AnalysisPanel({
    required this.state,
    required this.classification,
  });

  final ReviewState state;
  final MoveClassification? classification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.currentPlyIndex == 0) {
      return _StartingPositionPanel(state: state);
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          top: BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Move + badge
            if (state.game != null &&
                state.currentPlyIndex > 0 &&
                state.currentPlyIndex <= state.game!.moves.length)
              Row(
                children: [
                  Text(
                    state.game!.moves[state.currentPlyIndex - 1].fullNotation,
                    style: AppTextStyles.monoLarge,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (classification != null)
                    ChtMoveBadge(
                      quality: classification!.quality,
                      showGlow: classification!.quality == MoveQuality.brilliant,
                    ),
                  if (state.isAnalyzing && classification == null)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: AppSpacing.md),

            // CPL + eval
            if (classification != null) ...[
              Row(
                children: [
                  _InfoChip(
                    label: 'CPL',
                    value: '${classification!.cpl}',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                    label: 'Eval',
                    value: classification!.engineLines.isNotEmpty
                        ? classification!.engineLines.first.evalDisplay
                        : '0.00',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                    label: 'Depth',
                    value: classification!.engineLines.isNotEmpty
                        ? '${classification!.engineLines.first.depth}'
                        : '-',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Plain language explanation
              Text(
                classification!.plainExplanation,
                style: AppTextStyles.bodyMuted,
              ),

              // Best move suggestion
              if (classification!.bestMove != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Best: ',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      classification!.bestMove!,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.lg),

            // Analyze deeper button
            ChtButton(
              label: 'Analyze Deeper',
              onPressed: state.isAnalyzing
                  ? null
                  : () => ref.read(reviewProvider.notifier).startAnalysis(),
              variant: ChtButtonVariant.secondary,
              icon: Icons.psychology_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartingPositionPanel extends StatelessWidget {
  const _StartingPositionPanel({required this.state});

  final ReviewState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          top: BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Starting Position', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          if (state.game?.opening != null)
            Text(state.game!.opening!, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Press ▶ to begin reviewing moves',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _InfoChip(
                label: 'Moves',
                value: '${state.totalPlies}',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              if (state.game?.result != null)
                _InfoChip(
                  label: 'Result',
                  value: state.game!.result,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.monoSmall,
          ),
          Text(
            value,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Desktop/tablet: side-by-side board + analysis ────────────────────────────

class _WideReviewBody extends ConsumerWidget {
  const _WideReviewBody({required this.state, required this.storage});

  final ReviewState state;
  final StorageService storage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = state.currentBoardState;
    final currentClassification = state.classificationAt(state.currentPlyIndex);
    final evalCp = currentClassification?.evalAfter ?? 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left panel: eval bar + board + controls + notation ──────────────
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // Board area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      // Eval bar
                      AnimatedEvalBar(
                        evalCp: evalCp,
                        height: double.infinity,
                        width: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Chess board — square, fills available height
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: boardState != null
                                ? ChessBoardWidget(
                                    boardState: boardState,
                                    pieceSetId: storage.pieceSet,
                                    boardThemeId: storage.boardTheme,
                                    showCoordinates: storage.showCoordinates,
                                    highlightLastMove: storage.highlightLastMove,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.grid_on_rounded,
                                      color: AppColors.textSecondary,
                                      size: 64,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation controls
              _NavigationControls(state: state),

              // Move notation strip
              _MoveNotationStrip(state: state),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),

        // Vertical divider
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: AppColors.primaryBorder,
        ),

        // ── Right panel: analysis panel (scrollable) ─────────────────────────
        SizedBox(
          width: 340,
          child: _AnalysisPanel(
            state: state,
            classification: currentClassification,
          ),
        ),
      ],
    );
  }
}
