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
  bool _isFlipped = false;

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
      {super.key,
      required this.state,
      required this.settings,
      required this.isFlipped});
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Eval Bar
                    AnimatedEvalBar(
                      evalCp: isFlipped ? -evalCp : evalCp,
                      height: MediaQuery.of(context).size.width - 64,
                      width: 8,
                    ),
                    const SizedBox(width: 12),
                    // Chess Board
                    Expanded(
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
              const SizedBox(height: 32),
              // Navigation Controls
              _NavigationControls(state: state),
              const SizedBox(height: 24),
              // Move Notation Strip
              _MoveNotationStrip(state: state),
            ],
          ),
        ),

        // Bottom Analysis Panel
        _AnalysisPanel(state: state, classification: classification),
      ],
    );
  }
}

class _NavigationControls extends ConsumerWidget {
  const _NavigationControls({super.key, required this.state});
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
  const _NavIconButton(
      {super.key, required this.icon, this.onTap, this.large = false});
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
            color: onTap == null ? Colors.transparent : AppColors.color1,
            border: onTap == null
                ? null
                : Border.all(color: AppColors.divider, width: 1),
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
  const _MoveNotationStrip({super.key, required this.state});
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
  const _AnalysisPanel(
      {super.key, required this.state, required this.classification});
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (classification != null) ...[
            Row(
              children: [
                Text(state.game!.moves[state.currentPlyIndex - 1].san,
                    style: AppTextStyles.monoLarge
                        .copyWith(color: Colors.white, fontSize: 24)),
                const SizedBox(width: 16),
                _ClassificationTinyBadge(quality: classification!.quality),
              ],
            ),
            const SizedBox(height: 12),
            Text(classification!.plainExplanation,
                style: AppTextStyles.body.copyWith(color: Colors.white70)),
          ] else
            const Text('SELECT A MOVE TO ANALYZE',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ChtButton(
            label: state.isAnalyzing ? 'ANALYZING...' : 'RUN ANALYSIS',
            onPressed: state.isAnalyzing
                ? null
                : () => ref.read(reviewProvider.notifier).startAnalysis(),
            icon: Icons.psychology_rounded,
            height: 48,
          ),
        ],
      ),
    );
  }
}

class _ClassificationTinyBadge extends StatelessWidget {
  const _ClassificationTinyBadge({super.key, required this.quality});
  final MoveQuality quality;
  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
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

  (IconData, Color, String) _config() {
    return switch (quality) {
      MoveQuality.brilliant => (
          Icons.auto_awesome,
          AppColors.brilliant,
          'BRILLIANT'
        ),
      MoveQuality.great => (Icons.thumb_up_rounded, AppColors.great, 'GREAT'),
      MoveQuality.best => (Icons.star_rounded, AppColors.primary, 'BEST'),
      _ => (Icons.check_rounded, AppColors.good, 'GOOD'),
    };
  }
}

class _WideReviewBody extends StatelessWidget {
  const _WideReviewBody(
      {super.key,
      required this.state,
      required this.settings,
      required this.isFlipped});
  final ReviewState state;
  final SettingsState settings;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('WIDE VIEW NOT IMPLEMENTED',
            style: TextStyle(color: Colors.white)));
  }
}
