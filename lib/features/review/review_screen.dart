import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/eval_bar.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/settings_provider.dart';
import '../../core/utils/responsive.dart';
import '../../engine/move_classifier.dart';
import '../../engine/opening_book.dart';
import 'board/chess_board_widget.dart';
import 'analysis/review_notifier.dart';
import 'analysis/recording_export_widget.dart';
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
  bool _isFlipped = false;
  final GlobalKey _exportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moveIndexStr =
          GoRouterState.of(context).uri.queryParameters['move'];
      final startAtMove = int.tryParse(moveIndexStr ?? '');

      ref.read(reviewProvider.notifier).loadGame(
            widget.pgn,
            gameId: widget.gameId,
            startAtMove: startAtMove,
          );
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

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSurface,
        title: Text('EXIT REVIEW?',
            style: AppTextStyles.title
                .copyWith(color: Colors.white, letterSpacing: 1)),
        content: const Text('Do you want to stop analysis and return?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('EXIT',
                style: TextStyle(
                    color: AppColors.loss, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);
    final settings = ref.watch(settingsProvider);
    final storage = ref.read(storageServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGameEnd(state));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        appBar: AppBar(
          title: Text('GAME REVIEW',
              style: AppTextStyles.headline.copyWith(
                  fontSize: 16, letterSpacing: 2, color: Colors.white)),
          centerTitle: true,
          backgroundColor: AppColors.backgroundDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) context.pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                  state.isExporting
                      ? Icons.hourglass_top_rounded
                      : Icons.videocam_rounded,
                  size: 22,
                  color:
                      state.isExporting ? AppColors.secondary : Colors.white),
              onPressed: state.isExporting
                  ? null
                  : () async {
                      final path = await ref
                          .read(reviewProvider.notifier)
                          .exportVideo(_exportKey);
                      if (mounted && path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Video saved to: $path'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded,
                  size: 20, color: Colors.white),
              onPressed: () {
                final ply = state.currentPlyIndex;
                final move = ply > 0 ? state.game?.moves[ply - 1].san : 'start';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Game state at move $move shared!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded,
                  size: 22, color: Colors.white),
              onPressed: () => setState(() => _isFlipped = !_isFlipped),
            ),
            if (state.isAnalyzing)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
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
                child: CircularProgressIndicator(color: AppColors.primary))
            : state.error != null
                ? ChtErrorState(
                    title: 'ERROR',
                    description: state.error!,
                    onRetry: () =>
                        ref.read(reviewProvider.notifier).loadGame(widget.pgn),
                  )
                : Stack(
                    children: [
                      // Off-screen widget for video export
                      if (state.isExporting)
                        Positioned(
                          left: -2000, // Hide it far off-screen
                          child: RepaintBoundary(
                            child: RecordingExportWidget(
                              boardState: state.currentBoardState!,
                              pieceSetId: settings.pieceSet,
                              boardThemeId: settings.boardTheme,
                              openingName: OpeningBook.getOpeningName(
                                      state.currentBoardState!.fen) ??
                                  'CHESS GAME',
                              moveNotation: state.currentPlyIndex > 0
                                  ? state.game!.moves[state.currentPlyIndex - 1]
                                      .fullNotation
                                  : 'START',
                              moveQuality: state
                                  .classificationAt(state.currentPlyIndex)
                                  ?.quality,
                              isFlipped: _isFlipped,
                              captureKey: _exportKey,
                            ),
                          ),
                        ),

                      context.isWide
                          ? _WideReviewBody(
                              state: state,
                              settings: settings,
                              isFlipped: _isFlipped)
                          : _ReviewBody(
                              state: state,
                              settings: settings,
                              isFlipped: _isFlipped),
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
      ),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody(
      {required this.state, required this.settings, required this.isFlipped});
  final ReviewState state;
  final SettingsState settings;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final boardState = state.currentBoardState;
    final classification = state.classificationAt(state.currentPlyIndex);
    final evalCp = classification?.evalAfter ?? 0.0;

    return Column(
      children: [
        // Board Section
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Eval Bar (Fixed height relative to screen width to prevent glitching)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              math.min(MediaQuery.of(context).size.width, 400),
                        ),
                        child: AnimatedEvalBar(
                          evalCp: isFlipped ? -evalCp : evalCp,
                          height: 360, // Fixed stable height
                          width: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Chess Board
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: boardState != null
                                  ? ChessBoardWidget(
                                      boardState: state.isRetryMode
                                          ? boardState.copyWith(
                                              bestMoveFrom:
                                                  boardState.lastMoveFrom,
                                              bestMoveTo: boardState.lastMoveTo,
                                            )
                                          : boardState,
                                      pieceSetId: settings.pieceSet,
                                      boardThemeId: settings.boardTheme,
                                      showCoordinates: settings.showCoordinates,
                                      highlightLastMove:
                                          settings.highlightLastMove,
                                      moveQuality: classification?.quality,
                                      isFlipped: isFlipped,
                                    )
                                  : Container(
                                      color: AppColors.backgroundSurface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // Balance
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _NavigationControls(state: state),
                const SizedBox(height: 20),
                _MoveNotationStrip(state: state),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        // Bottom Analysis Panel
        _AnalysisPanel(state: state, classification: classification),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavIconButton(
            icon: Icons.first_page_rounded,
            onTap: state.isAtStart ? null : notifier.goToStart),
        const SizedBox(width: 16),
        _NavIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: state.isAtStart ? null : notifier.goBack,
            large: true),
        const SizedBox(width: 32),
        _NavIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: state.isAtEnd ? null : notifier.goForward,
            large: true),
        const SizedBox(width: 16),
        _NavIconButton(
            icon: Icons.last_page_rounded,
            onTap: state.isAtEnd ? null : notifier.goToEnd),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, this.onTap, this.large = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: EdgeInsets.all(large ? 14 : 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? Colors.transparent : Colors.white10,
            border: onTap == null
                ? null
                : Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(icon,
              color: onTap == null ? AppColors.textDisabled : Colors.white,
              size: large ? 32 : 24),
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
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.game!.moves.length,
        itemBuilder: (context, i) {
          final ply = i + 1;
          final move = state.game!.moves[i];
          final isActive = ply == state.currentPlyIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(move.san,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.bold : null)),
              selected: isActive,
              onSelected: (_) => ref.read(reviewProvider.notifier).goToPly(ply),
              selectedColor: AppColors.color3,
              backgroundColor: AppColors.color1,
              side: BorderSide(
                  color: isActive ? AppColors.primary : AppColors.divider),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}

class _AnalysisPanel extends ConsumerWidget {
  const _AnalysisPanel({required this.state, required this.classification});
  final ReviewState state;
  final MoveClassification? classification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child:
          _AnalysisPanelContent(state: state, classification: classification),
    );
  }
}

class _AnalysisPanelContent extends ConsumerWidget {
  const _AnalysisPanelContent(
      {required this.state, required this.classification});
  final ReviewState state;
  final MoveClassification? classification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isRetryMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('RETRY MODE',
                  style: AppTextStyles.monoLarge
                      .copyWith(color: AppColors.secondary, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
              'Try to find a better move than the one played. The best move is now highlighted with an arrow as a hint!',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          ChtButton(
            label: 'EXIT RETRY',
            onPressed: () =>
                ref.read(reviewProvider.notifier).toggleRetryMode(),
            icon: Icons.close_rounded,
            height: 48,
            variant: ChtButtonVariant.ghost,
          ),
        ],
      );
    }

    final openingName = state.currentBoardState != null
        ? OpeningBook.getOpeningName(state.currentBoardState!.fen)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (classification != null) ...[
          Row(
            children: [
              Text(state.game!.moves[state.currentPlyIndex - 1].fullNotation,
                  style: AppTextStyles.monoLarge
                      .copyWith(color: Colors.white, fontSize: 24)),
              const SizedBox(width: 16),
              _ClassificationTinyBadge(quality: classification!.quality),
            ],
          ),
          const SizedBox(height: 12),
          Text(openingName ?? classification!.plainExplanation,
              style: AppTextStyles.body.copyWith(
                color: openingName != null ? AppColors.primary : Colors.white70,
                fontWeight: openingName != null ? FontWeight.bold : null,
              )),
          if (classification!.quality != MoveQuality.best &&
              classification!.bestMove != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text('BEST MOVE: ',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Text(classification!.bestMove!,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ] else
          const Text('SELECT A MOVE TO ANALYZE',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        if (!state.isRetryMode &&
            classification != null &&
            (classification!.quality == MoveQuality.blunder ||
                classification!.quality == MoveQuality.mistake ||
                classification!.quality == MoveQuality.inaccuracy))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChtButton(
              label: 'RETRY THIS MOVE',
              onPressed: () =>
                  ref.read(reviewProvider.notifier).toggleRetryMode(),
              icon: Icons.refresh_rounded,
              height: 48,
              variant: ChtButtonVariant.secondary,
            ),
          ),
        ChtButton(
          label: state.isAnalyzing ? 'ANALYZING...' : 'RUN DEEP ANALYSIS',
          onPressed: state.isAnalyzing
              ? null
              : () => ref.read(reviewProvider.notifier).startAnalysis(),
          icon: Icons.psychology_rounded,
          height: 52,
        ),
      ],
    );
  }
}

class _ClassificationTinyBadge extends StatelessWidget {
  const _ClassificationTinyBadge({required this.quality});
  final MoveQuality quality;
  @override
  Widget build(BuildContext context) {
    final (asset, color, label) = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, width: 16, height: 16, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  (String, Color, String) _config() {
    return switch (quality) {
      MoveQuality.brilliant => (
          'assets/classification/brilliant.png',
          AppColors.brilliant,
          'BRILLIANT'
        ),
      MoveQuality.great => (
          'assets/classification/excellent.png',
          AppColors.great,
          'GREAT'
        ),
      MoveQuality.best => (
          'assets/classification/best.png',
          AppColors.primary,
          'BEST'
        ),
      MoveQuality.good => (
          'assets/classification/very_good.png',
          AppColors.good,
          'GOOD'
        ),
      MoveQuality.book => (
          'assets/classification/book.png',
          AppColors.book,
          'BOOK'
        ),
      MoveQuality.inaccuracy => (
          'assets/classification/inaccuracy.png',
          AppColors.inaccuracy,
          'INACCURACY'
        ),
      MoveQuality.mistake => (
          'assets/classification/mistake.png',
          AppColors.mistake,
          'MISTAKE'
        ),
      MoveQuality.blunder => (
          'assets/classification/blunder.png',
          AppColors.blunder,
          'BLUNDER'
        ),
      MoveQuality.miss => (
          'assets/classification/sigma.png',
          AppColors.miss,
          'MISS'
        ),
      _ => ('assets/classification/good.png', AppColors.good, 'GOOD'),
    };
  }
}

class _WideReviewBody extends StatelessWidget {
  const _WideReviewBody({
    required this.state,
    required this.settings,
    required this.isFlipped,
  });

  final ReviewState state;
  final SettingsState settings;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final boardState = state.currentBoardState;
    final classification = state.classificationAt(state.currentPlyIndex);
    final evalCp = classification?.evalAfter ?? 0.0;

    return Row(
      children: [
        // Left: Eval bar and Board
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedEvalBar(
                      evalCp: isFlipped ? -evalCp : evalCp,
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: 12,
                    ),
                    const SizedBox(width: 32),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.height * 0.7,
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: boardState != null
                            ? ChessBoardWidget(
                                boardState: boardState,
                                pieceSetId: settings.pieceSet,
                                boardThemeId: settings.boardTheme,
                                showCoordinates: settings.showCoordinates,
                                highlightLastMove: settings.highlightLastMove,
                                moveQuality: classification?.quality,
                                isFlipped: isFlipped,
                              )
                            : Container(color: AppColors.backgroundSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _NavigationControls(state: state),
              const SizedBox(height: 24),
              _MoveNotationStrip(state: state),
            ],
          ),
        ),

        // Right: Analysis Panel
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSurface,
              border:
                  Border(left: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: _AnalysisPanelContent(
                  state: state, classification: classification),
            ),
          ),
        ),
      ],
    );
  }
}
