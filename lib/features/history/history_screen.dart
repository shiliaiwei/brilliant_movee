import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_badge.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/game_repository.dart';

// Filter state
enum GameFilter { all, win, loss, draw, bullet, blitz, rapid }

final _historyFilterProvider =
    StateProvider<GameFilter>((ref) => GameFilter.all);

final _historyGamesProvider =
    FutureProvider.autoDispose<List<GameModel>>((ref) async {
  final username = ref.read(storageServiceProvider).connectedUsername;
  if (username == null) return [];
  return ref.read(gameRepositoryProvider).getRecentGames(username);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.read(storageServiceProvider).connectedUsername;
    final gamesAsync = ref.watch(_historyGamesProvider);
    final filter = ref.watch(_historyFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Analysis History'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => ref.invalidate(_historyGamesProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: filter,
            onSelect: (f) =>
                ref.read(_historyFilterProvider.notifier).state = f,
          ),
          const Divider(),
          Expanded(
            child: gamesAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 8,
                itemBuilder: (_, __) => const GameCardShimmer(),
              ),
              error: (e, _) => ChtErrorState(
                title: 'Failed to load games',
                description:
                    'Could not fetch your recent games from Chess.com.',
                onRetry: () => ref.invalidate(_historyGamesProvider),
              ),
              data: (games) {
                final filtered = _applyFilter(games, filter, username ?? '');
                if (filtered.isEmpty) {
                  return ChtEmptyState(
                    title: 'No games found',
                    description: filter == GameFilter.all
                        ? 'Try connecting your account or playing some games.'
                        : 'No games match your current filter.',
                    icon: Icons.history_rounded,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(_historyGamesProvider),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _EnhancedGameCard(
                      game: filtered[i],
                      username: username ?? '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<GameModel> _applyFilter(
      List<GameModel> games, GameFilter filter, String username) {
    return games.where((g) {
      switch (filter) {
        case GameFilter.all:
          return true;
        case GameFilter.win:
          final r = g.resultFor(username);
          return (r == '1-0' &&
                  g.whiteUsername.toLowerCase() == username.toLowerCase()) ||
              (r == '0-1' &&
                  g.blackUsername.toLowerCase() == username.toLowerCase());
        case GameFilter.loss:
          final r = g.resultFor(username);
          return (r == '0-1' &&
                  g.whiteUsername.toLowerCase() == username.toLowerCase()) ||
              (r == '1-0' &&
                  g.blackUsername.toLowerCase() == username.toLowerCase());
        case GameFilter.draw:
          return g.result == '1/2-1/2';
        case GameFilter.bullet:
          return g.timeControl == TimeControl.bullet;
        case GameFilter.blitz:
          return g.timeControl == TimeControl.blitz;
        case GameFilter.rapid:
          return g.timeControl == TimeControl.rapid;
      }
    }).toList();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});
  final GameFilter selected;
  final ValueChanged<GameFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: GameFilter.values.map((f) {
          final isSelected = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f.name.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => onSelect(f),
              labelStyle: AppTextStyles.badge.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 9,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.backgroundSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EnhancedGameCard extends StatefulWidget {
  const _EnhancedGameCard({required this.game, required this.username});
  final GameModel game;
  final String username;

  @override
  State<_EnhancedGameCard> createState() => _EnhancedGameCardState();
}

class _EnhancedGameCardState extends State<_EnhancedGameCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final res = widget.game.resultFor(widget.username);
    final isWhite = widget.game.whiteUsername.toLowerCase() ==
        widget.username.toLowerCase();
    final opponent =
        isWhite ? widget.game.blackUsername : widget.game.whiteUsername;
    final oppRating =
        isWhite ? widget.game.blackRating : widget.game.whiteRating;

    final statusColor = res == '1-0'
        ? AppColors.win
        : (res == '0-1' ? AppColors.loss : AppColors.draw);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          ChtCard(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderColor: _isExpanded ? AppColors.primary : AppColors.divider,
            child: Column(
              children: [
                Row(
                  children: [
                    _MiniBoard(color: statusColor),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ChtResultBadge(result: res),
                              const SizedBox(width: AppSpacing.xs),
                              ChtBadge(
                                  label: widget.game.timeControlLabel,
                                  color: AppColors.book,
                                  compact: true),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'vs $opponent ($oppRating)',
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.game.terminationFor(widget.username),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ChtButton(
                          label: 'Analysis',
                          onPressed: () => context.push(AppRoutes.review,
                              extra: widget.game.pgn),
                          icon: Icons.analytics_rounded,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ChtButton(
                          label: 'Review',
                          onPressed: () => context.push(AppRoutes.review,
                              extra: widget.game.pgn),
                          icon: Icons.auto_awesome_mosaic_rounded,
                          height: 40,
                          variant: ChtButtonVariant.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _MiniBoard extends StatelessWidget {
  const _MiniBoard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Icon(Icons.grid_3x3_rounded,
            color: color.withValues(alpha: 0.5), size: 24),
      ),
    );
  }
}
