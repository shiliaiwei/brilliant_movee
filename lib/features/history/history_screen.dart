import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/game_repository.dart';

import 'package:intl/intl.dart';

final _historyGamesProvider =
    FutureProvider.autoDispose<List<GameModel>>((ref) async {
  final username = ref.watch(connectedUsernameProvider);
  if (username == null) return [];
  // Forcing refresh to ensure history updates as requested
  return ref
      .read(gameRepositoryProvider)
      .getRecentGames(username, forceRefresh: true);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(connectedUsernameProvider);
    final gamesAsync = ref.watch(_historyGamesProvider);

    if (username == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        appBar: AppBar(
          title: const Text('GAMES HISTORY'),
          centerTitle: true,
          backgroundColor: AppColors.backgroundDeep,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: AppSpacing.lg),
              Text('No account connected', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xxl),
              ChtButton(
                label: 'Connect Account',
                onPressed: () => context.push(AppRoutes.search),
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('GAMES HISTORY'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => ref.invalidate(_historyGamesProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: gamesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
            child:
                Text('Failed to load history', style: AppTextStyles.bodyMuted),
          ),
          data: (games) {
            if (games.isEmpty) {
              return Center(child: _NoGamesCard(username: username));
            }

            final grouped = _groupGamesByDate(games);

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(_historyGamesProvider),
              color: AppColors.primary,
              backgroundColor: AppColors.backgroundSurface,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(20),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final group = grouped[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Row(
                          children: [
                            Text(
                              group.dateLabel.toUpperCase(),
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${group.games.length} Games',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      ...group.games.map((g) => _GameFeedItem(
                            game: g,
                            currentUsername: username,
                          )),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  List<_GameGroup> _groupGamesByDate(List<GameModel> games) {
    final Map<String, List<GameModel>> map = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final game in games) {
      final date = game.endDateTime;
      final d = DateTime(date.year, date.month, date.day);
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(d);
      }

      if (!map.containsKey(label)) map[label] = [];
      map[label]!.add(game);
    }

    return map.entries
        .map((e) => _GameGroup(dateLabel: e.key, games: e.value))
        .toList();
  }
}

class _GameGroup {
  final String dateLabel;
  final List<GameModel> games;
  _GameGroup({required this.dateLabel, required this.games});
}

class _GameFeedItem extends ConsumerWidget {
  const _GameFeedItem({required this.game, required this.currentUsername});
  final GameModel game;
  final String currentUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = game.resultFor(currentUsername);
    final statusColor = res == '1-0'
        ? AppColors.win
        : (res == '0-1' ? AppColors.loss : AppColors.draw);

    final shortResult = _getShortResult(game, currentUsername);
    final storage = ref.watch(storageServiceProvider);
    final isReviewed =
        storage.brilliantGamesData.any((json) => json.contains(game.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChtCard(
        onTap: () => context.push(AppRoutes.review, extra: game.pgn),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(res),
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.whiteUsername == currentUsername
                        ? game.blackUsername
                        : game.whiteUsername,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        game.timeControlLabel,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      if (isReviewed)
                        const Text(
                          '• REVIEWED',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shortResult.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(game.endDateTime),
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String res) {
    if (res == '1/2-1/2') return Icons.handshake_rounded;
    if (res == '1-0') return Icons.emoji_events_rounded;
    return Icons.close_rounded;
  }

  String _getShortResult(GameModel game, String username) {
    return game.terminationFor(username);
  }
}

class _NoGamesCard extends StatelessWidget {
  const _NoGamesCard({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded,
              color: AppColors.textSecondary, size: 36),
          const SizedBox(height: AppSpacing.md),
          Text('No recent games found', style: AppTextStyles.body),
          Text(
            'Play some games on Chess.com first',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
