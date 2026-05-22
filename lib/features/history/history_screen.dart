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
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/game_repository.dart';

// Filter state
enum GameFilter { all, win, loss, draw, bullet, blitz, rapid }

final _historyFilterProvider = StateProvider<GameFilter>((ref) => GameFilter.all);

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
        title: const Text('Game History'),
        backgroundColor: AppColors.backgroundDeep,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(_historyGamesProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar — centered on wide screens
          _FilterBar(
            selected: filter,
            onSelect: (f) => ref.read(_historyFilterProvider.notifier).state = f,
          ),

          // Games list
          Expanded(
            child: gamesAsync.when(
              loading: () => ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => const GameCardShimmer(),
              ),
              error: (e, _) => ChtErrorState(
                title: 'Failed to load games',
                description: 'Could not fetch game history. Check your connection.',
                onRetry: () => ref.invalidate(_historyGamesProvider),
              ),
              data: (games) {
                final filtered = _applyFilter(games, filter, username ?? '');
                if (filtered.isEmpty) {
                  return ChtEmptyState(
                    title: 'No games found',
                    description: filter == GameFilter.all
                        ? 'Play some games on Chess.com to see them here.'
                        : 'No games match the selected filter.',
                    icon: Icons.sports_esports_rounded,
                    ctaLabel: filter != GameFilter.all ? 'Show All' : null,
                    onCta: filter != GameFilter.all
                        ? () => ref
                            .read(_historyFilterProvider.notifier)
                            .state = GameFilter.all
                        : null,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.backgroundElevated,
                  onRefresh: () async => ref.invalidate(_historyGamesProvider),
                  child: context.isWide
                      ? _WideGamesList(games: filtered, username: username ?? '')
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _GameCard(
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
    List<GameModel> games,
    GameFilter filter,
    String username,
  ) {
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

  static const _filters = [
    (GameFilter.all, 'All'),
    (GameFilter.win, 'Win'),
    (GameFilter.loss, 'Loss'),
    (GameFilter.draw, 'Draw'),
    (GameFilter.bullet, 'Bullet'),
    (GameFilter.blitz, 'Blitz'),
    (GameFilter.rapid, 'Rapid'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final (filter, label) = _filters[i];
          final isSelected = filter == selected;
          return Center(
            child: GestureDetector(
              onTap: () => onSelect(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGlow
                      : AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.username});

  final GameModel game;
  final String username;

  @override
  Widget build(BuildContext context) {
    final result = game.resultFor(username);
    final isWhite = game.whiteUsername.toLowerCase() == username.toLowerCase();
    final opponent = isWhite ? game.blackUsername : game.whiteUsername;
    final accuracy = game.accuracyFor(username);

    final resultColor = result == '1-0' && isWhite || result == '0-1' && !isWhite
        ? AppColors.win
        : result == '1/2-1/2'
            ? AppColors.draw
            : AppColors.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: ChtCard(
        onTap: () => context.go(AppRoutes.review, extra: game.pgn),
        borderColor: resultColor.withValues(alpha: 0.2),
        child: Row(
          children: [
            // Mini board
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: resultColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.grid_on_rounded,
                color: resultColor.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChtResultBadge(result: result),
                      const SizedBox(width: AppSpacing.sm),
                      ChtBadge(
                        label: game.timeControlLabel,
                        color: AppColors.book,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'vs $opponent',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        _formatDate(game.endDateTime),
                        style: AppTextStyles.caption,
                      ),
                      if (accuracy != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${accuracy.toStringAsFixed(1)}%',
                          style: AppTextStyles.captionPrimary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Desktop/tablet: 2-column grid of game cards
class _WideGamesList extends StatelessWidget {
  const _WideGamesList({required this.games, required this.username});

  final List<GameModel> games;
  final String username;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isDesktop ? 3 : 2;
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: AppSpacing.md,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.8,
      ),
      itemCount: games.length,
      itemBuilder: (context, i) =>
          _GameCard(game: games[i], username: username),
    );
  }
}
