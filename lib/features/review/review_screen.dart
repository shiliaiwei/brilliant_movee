import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/eval_bar.dart';
import '../../core/widgets/fui_loading.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/settings_provider.dart';
import '../../core/utils/responsive.dart';
import '../../engine/move_classifier.dart';
import '../../engine/opening_book.dart';
import 'board/chess_board_widget.dart';
import 'analysis/review_notifier.dart';
import 'analysis/recording_export_widget.dart';
import 'celebrate/celebrate_overlay.dart';
import 'widgets/review_cyber_action_button.dart';

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

  Future<void> _showRecordingSettings() async {
    // Request permission first for Android
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      // Permission granted
    }

    if (!mounted) return;

    final state = ref.read(reviewProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _RecordingSettingsSheet(
        state: state,
        onStart: () async {
          final messenger = ScaffoldMessenger.of(context);
          final path =
              await ref.read(reviewProvider.notifier).exportVideo(_exportKey);
          if (path != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Video saved to: $path'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
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
    final settings = ref.watch(settingsProvider);
    final storage = ref.read(storageServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGameEnd(state));

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('GAME REVIEW',
              style: AppTextStyles.headline.copyWith(
                  fontSize: 16, letterSpacing: 2, color: Colors.white)),
          centerTitle: true,
          backgroundColor: AppColors.backgroundDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.white),
            onPressed: () => context.pop(),
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
              onPressed: state.isExporting ? null : _showRecordingSettings,
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: FuiLoading(label: 'INITIALIZING ANALYSIS'))
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
                          left: -3000, // Hide it far off-screen
                          child: RepaintBoundary(
                            key: _exportKey,
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
                              isFlipped: false,
                              captureKey: _exportKey,
                            ),
                          ),
                        ),

                      Column(
                        children: [
                          _AnalysisPanelSimplified(
                              state: state,
                              engineVersion: settings.engineVersion),
                          Expanded(
                            child: context.isWide
                                ? _WideReviewBody(
                                    state: state, settings: settings)
                                : _ReviewBody(state: state, settings: settings),
                          ),
                        ],
                      ),

                      if (state.brilliantAlert)
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: _BrilliantAlert(
                            onDismiss: () => ref
                                .read(reviewProvider.notifier)
                                .dismissBrilliantAlert(),
                          ),
                        ),

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

class _ReviewBody extends ConsumerWidget {
  const _ReviewBody({required this.state, required this.settings});
  final ReviewState state;
  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = state.currentBoardState;
    final classification = state.classificationAt(state.currentPlyIndex);
    final storage = ref.read(storageServiceProvider);
    final user = storage.connectedUsername?.toLowerCase() ?? '';

    final white = state.game?.white ?? 'White';
    final black = state.game?.black ?? 'Black';

    final isUserWhite = white.toLowerCase() == user;
    final opponent = isUserWhite ? black : white;
    final userDisplayName = isUserWhite ? white : black;
    final bool boardFlipped = !isUserWhite;

    String? currentOpening;
    for (int i = 0; i <= state.currentPlyIndex; i++) {
      if (i >= state.boardStates.length) break;
      final fen = state.boardStates[i].fen;
      final name = OpeningBook.getOpeningName(fen);
      if (name != null) currentOpening = name;
    }

    final move = state.currentPlyIndex > 0
        ? state.game!.moves[state.currentPlyIndex - 1]
        : null;
    final currentMoveStr =
        move != null ? '${move.moveNumber}${move.san}' : 'START';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _PlayerBadge(name: opponent, isTop: true),
        ),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (currentOpening ?? 'CHESS GAME').toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                if (classification != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    classification.qualityLabel.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side =
                  math.min(constraints.maxWidth, constraints.maxHeight) * 0.98;

              return Center(
                child: SizedBox(
                  width: side,
                  height: side,
                  child: boardState != null
                      ? ChessBoardWidget(
                          boardState: state.isRetryMode
                              ? boardState.copyWith(
                                  bestMoveFrom: boardState.lastMoveFrom,
                                  bestMoveTo: boardState.lastMoveTo,
                                )
                              : boardState,
                          pieceSetId: settings.pieceSet,
                          boardThemeId: settings.boardTheme,
                          showCoordinates: settings.showCoordinates,
                          highlightLastMove: settings.highlightLastMove,
                          moveQuality: classification?.quality,
                          isFlipped: boardFlipped,
                          animate: !state.isExporting,
                        )
                      : Container(color: AppColors.backgroundSurface),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _PlayerBadge(name: userDisplayName, isTop: false),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              if (move != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Text(
                    currentMoveStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _NavigationControls(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.name, required this.isTop});
  final String name;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child:
              const Icon(Icons.person_rounded, size: 18, color: Colors.white24),
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        if (isTop)
          const Icon(Icons.arrow_drop_up_rounded, color: Colors.white10)
        else
          const Icon(Icons.arrow_drop_down_rounded, color: Colors.white10),
      ],
    );
  }
}

class _AnalysisPanelSimplified extends ConsumerStatefulWidget {
  const _AnalysisPanelSimplified(
      {required this.state, required this.engineVersion});
  final ReviewState state;
  final int engineVersion;

  @override
  ConsumerState<_AnalysisPanelSimplified> createState() =>
      _AnalysisPanelSimplifiedState();
}

class _AnalysisPanelSimplifiedState
    extends ConsumerState<_AnalysisPanelSimplified>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isAnalyzing) return const SizedBox(height: 16);

    final storage = ref.read(storageServiceProvider);
    final depth = storage.engineDepth;
    final mode = depth >= 30
        ? 'GRANDMASTER'
        : depth >= 26
            ? 'PREMIUM'
            : depth >= 22
                ? 'BALANCED'
                : 'FAST';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ANALYZING...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SF-${widget.engineVersion} • $mode',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${(widget.state.analysisProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Thicker Fill Loading Bar
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Stack(
              children: [
                // Progressive Fill
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.state.analysisProgress,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF00E5FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Shimmer Effect Overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              (_controller.value * 2 - 1) *
                                  MediaQuery.of(context).size.width,
                              0),
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0),
                                ],
                                transform: const GradientRotation(0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrilliantAlert extends StatelessWidget {
  const _BrilliantAlert({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE9B200).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE9B200).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/classification/brilliant.png',
                  width: 24, height: 24),
              const SizedBox(width: 12),
              const Text(
                'BRILLIANT MOVE !!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut)
            .fadeOut(delay: 2.seconds, duration: 500.ms),
      ),
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

class _WideReviewBody extends StatelessWidget {
  const _WideReviewBody({
    required this.state,
    required this.settings,
  });

  final ReviewState state;
  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    final boardState = state.currentBoardState;
    final classification = state.classificationAt(state.currentPlyIndex);
    final evalCp = classification?.evalAfter ?? 0.0;

    return Row(
      children: [
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
                      evalCp: evalCp,
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
                              )
                            : Container(color: AppColors.backgroundSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _NavigationControls(state: state),
            ],
          ),
        ),
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
          ReviewCyberActionButton(
            label: 'EXIT RETRY',
            onPressed: () =>
                ref.read(reviewProvider.notifier).toggleRetryMode(),
            icon: Icons.close_rounded,
            variant: CyberButtonVariant.tertiary,
            size: CyberButtonSize.medium,
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
            child: ReviewCyberActionButton(
              label: 'RETRY THIS MOVE',
              onPressed: () =>
                  ref.read(reviewProvider.notifier).toggleRetryMode(),
              icon: Icons.refresh_rounded,
              variant: CyberButtonVariant.secondary,
              size: CyberButtonSize.medium,
            ),
          ),
        ReviewCyberActionButton(
          label: state.isAnalyzing ? 'ANALYZING...' : 'RUN DEEP ANALYSIS',
          onPressed: state.isAnalyzing
              ? null
              : () => ref.read(reviewProvider.notifier).startAnalysis(),
          icon: Icons.psychology_rounded,
          variant: CyberButtonVariant.primary,
          size: CyberButtonSize.large,
          isLoading: state.isAnalyzing,
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
          _buildIcon(asset, color),
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

  Widget _buildIcon(String asset, Color color) {
    if (quality == MoveQuality.miss) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Color(0xFF8E24AA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 12,
        ),
      );
    }
    return Image.asset(asset, width: 16, height: 16, fit: BoxFit.contain);
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

class _RecordingSettingsSheet extends ConsumerStatefulWidget {
  const _RecordingSettingsSheet({required this.state, required this.onStart});
  final ReviewState state;
  final VoidCallback onStart;

  @override
  ConsumerState<_RecordingSettingsSheet> createState() =>
      _RecordingSettingsSheetState();
}

class _RecordingSettingsSheetState
    extends ConsumerState<_RecordingSettingsSheet> {
  String? _musicPath;
  double _volume = 0.5;
  Size _resolution = const Size(1080, 1080);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECORDING SETTINGS',
              style: AppTextStyles.headline
                  .copyWith(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Background Music',
                style: TextStyle(color: Colors.white)),
            subtitle: Text(_musicPath?.split('/').last ?? 'None selected',
                style: const TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.library_music_rounded,
                  color: AppColors.primary),
              onPressed: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.audio);
                if (result != null) {
                  setState(() => _musicPath = result.files.single.path);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Music Volume', style: TextStyle(color: Colors.white)),
              const Spacer(),
              Text('${(_volume * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _volume,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
            onChanged: (v) => setState(() => _volume = v),
          ),
          const SizedBox(height: 16),
          const Text('Resolution', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ResChip(
                label: '720p',
                selected: _resolution.width == 720,
                onTap: () => setState(() => _resolution = const Size(720, 720)),
              ),
              const SizedBox(width: 8),
              _ResChip(
                label: '1080p',
                selected: _resolution.width == 1080,
                onTap: () =>
                    setState(() => _resolution = const Size(1080, 1080)),
              ),
              const SizedBox(width: 8),
              _ResChip(
                label: '4K',
                selected: _resolution.width == 2160,
                onTap: () =>
                    setState(() => _resolution = const Size(2160, 2160)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ReviewCyberActionButton(
            label: 'START RECORDING',
            onPressed: () {
              Navigator.pop(context);
              ref.read(reviewProvider.notifier).setRecordingConfig(
                    musicPath: _musicPath,
                    volume: _volume,
                    resolution: _resolution,
                  );
              widget.onStart();
            },
            variant: CyberButtonVariant.primary,
            size: CyberButtonSize.large,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ResChip extends StatelessWidget {
  const _ResChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle:
          TextStyle(color: selected ? AppColors.primary : Colors.white70),
    );
  }
}
