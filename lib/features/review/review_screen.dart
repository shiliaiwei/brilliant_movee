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

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSurface,
        title: Text('Exit Review?', style: AppTextStyles.title),
        content: const Text('Do you want to stop the current analysis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit', style: TextStyle(color: AppColors.loss)),
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
          title: const Text('Game Review'),
          centerTitle: true,
          backgroundColor: AppColors.backgroundDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) context.pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded, size: 22),
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
                    title: 'Error',
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
        // Centered Board Section
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    AnimatedEvalBar(
                        evalCp: isFlipped ? -evalCp : evalCp,
                        height: 320,
                        width: 8),
                    const SizedBox(width: 8),
                    Expanded(
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
                          : const SizedBox.square(dimension: 300),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _NavigationControls(state: state),
              const SizedBox(height: 16),
              _MoveNotationStrip(state: state),
            ],
          ),
        ),

        // Analysis Footer
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
        const SizedBox(width: 12),
        _NavIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: state.isAtStart ? null : notifier.goBack,
            large: true),
        const SizedBox(width: 24),
        _NavIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: state.isAtEnd ? null : notifier.goForward,
            large: true),
        const SizedBox(width: 12),
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
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.all(large ? 12 : 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null
                ? Colors.transparent
                : AppColors.backgroundSurface,
          ),
          child: Icon(icon,
              color: onTap == null
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
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
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.game!.moves.length,
        itemBuilder: (context, i) {
          final ply = i + 1;
          final move = state.game!.moves[i];
          final isActive = ply == state.currentPlyIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(move.san,
                  style:
                      TextStyle(fontWeight: isActive ? FontWeight.bold : null)),
              selected: isActive,
              onSelected: (_) => ref.read(reviewProvider.notifier).goToPly(ply),
              selectedColor: AppColors.primaryGlow,
              backgroundColor: AppColors.backgroundSurface,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (classification != null) ...[
            Row(
              children: [
                Text(state.game!.moves[state.currentPlyIndex - 1].san,
                    style: AppTextStyles.monoLarge),
                const SizedBox(width: 12),
                _ClassificationTinyBadge(quality: classification!.quality),
              ],
            ),
            const SizedBox(height: 8),
            Text(classification!.plainExplanation,
                style: AppTextStyles.bodyMuted),
          ] else
            const Text('Analyze this position...',
                style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ChtButton(
            label: state.isAnalyzing ? 'Analyzing...' : 'Run Analysis',
            onPressed: state.isAnalyzing
                ? null
                : () => ref.read(reviewProvider.notifier).startAnalysis(),
            icon: Icons.psychology_rounded,
            height: 44,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
        child: Text('Wide view not implemented for Black theme yet.'));
  }
}
