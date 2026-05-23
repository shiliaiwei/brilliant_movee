import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/game_repository.dart';

final _homeTabProvider =
    StateProvider<int>((ref) => 0); // 0: Games, 1: Leaderboard

final _leaderboardCategoryProvider = StateProvider<String>((ref) => 'daily');

final _leaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardPlayer>>((ref) async {
  final category = ref.watch(_leaderboardCategoryProvider);
  return ref.read(playerRepositoryProvider).getTopPlayers(category);
});

final _homeGamesProvider =
    FutureProvider.autoDispose<List<GameModel>>((ref) async {
  final username = ref.watch(connectedUsernameProvider);
  if (username == null) return [];
  return ref.read(gameRepositoryProvider).getRecentGames(username);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) return;
    context.push('${AppRoutes.profile}?username=${value.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(connectedUsernameProvider);
    final selectedTab = ref.watch(_homeTabProvider);

    if (username == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDeep,
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
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  _BrandLogo(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: AppTextStyles.caption),
                        Text(username,
                            style:
                                AppTextStyles.headline.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined,
                        color: Colors.white70),
                    onPressed: () =>
                        context.push('${AppRoutes.profile}?username=$username'),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _TabButton(
                    label: 'MY GAMES',
                    isSelected: selectedTab == 0,
                    onTap: () => ref.read(_homeTabProvider.notifier).state = 0,
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'LEADERBOARD',
                    isSelected: selectedTab == 1,
                    onTap: () => ref.read(_homeTabProvider.notifier).state = 1,
                  ),
                ],
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: [
                  _MyGamesView(username: username),
                  _LeaderboardView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _MyGamesView extends ConsumerWidget {
  const _MyGamesView({required this.username});
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(_homeGamesProvider);

    return gamesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
          child: Text('Failed to load games', style: AppTextStyles.bodyMuted)),
      data: (games) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (games.isEmpty)
            SliverFillRemaining(
              child: Center(child: _NoGamesCard(username: username)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _GameFeedItem(
                    game: games[i],
                    currentUsername: username,
                  ),
                  childCount: games.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderboardView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(_leaderboardProvider);
    final selectedCategory = ref.watch(_leaderboardCategoryProvider);

    return Column(
      children: [
        // Category filters
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: ['daily', 'blitz', 'rapid', 'bullet', 'daily_puzzle']
                .map((cat) => _FilterChip(
                      label: cat.replaceAll('_', ' ').toUpperCase(),
                      isSelected: selectedCategory == cat,
                      onTap: () => ref
                          .read(_leaderboardCategoryProvider.notifier)
                          .state = cat,
                    ))
                .toList(),
          ),
        ),

        // Search Bar (within leaderboard)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                context.push('${AppRoutes.profile}?username=${v.trim()}');
              }
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search player username...',
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: Colors.white38),
              filled: true,
              fillColor: AppColors.backgroundSurface,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        Expanded(
          child: leaderboardAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => const Center(
                child: Text('Failed to load leaderboard',
                    style: TextStyle(color: Colors.white38))),
            data: (players) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: players.length,
              itemBuilder: (context, i) => _LeaderboardItem(player: players[i]),
            ),
          ),
        ),
      ],
    );
  }
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
            // Status Icon (Replacing #)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(res),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Usernames (White on top, Black on bottom)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.whiteUsername,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: game.whiteUsername.toLowerCase() ==
                              currentUsername.toLowerCase()
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.blackUsername,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: game.blackUsername.toLowerCase() ==
                              currentUsername.toLowerCase()
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                  if (isReviewed)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'REVIEWED',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Result Label
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
                  game.timeControlLabel,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
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
    final isWhite = game.whiteUsername.toLowerCase() == username.toLowerCase();
    final res = isWhite ? game.whiteResult : game.blackResult;

    if (res == 'win') return 'Won';
    if (res == 'checkmated') return 'Mate';
    if (res == 'resignation') return 'Resign';
    if (res == 'timeout') return 'Time';
    if (res == 'abandoned') return 'Aband';
    return 'Draw';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor:
            isSelected ? AppColors.primary : AppColors.backgroundSurface,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  const _LeaderboardItem({required this.player});
  final LeaderboardPlayer player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChtCard(
        onTap: () =>
            context.push('${AppRoutes.profile}?username=${player.username}'),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '#${player.rank}',
                style: AppTextStyles.monoSmall.copyWith(
                  color:
                      player.rank <= 3 ? AppColors.brilliant : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: ClipOval(
                child: player.avatar != null
                    ? CachedNetworkImage(
                        imageUrl: player.avatar!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.person, color: Colors.white24),
                      )
                    : const Icon(Icons.person, color: Colors.white24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.username,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (player.name != null)
                    Text(
                      player.name!,
                      style:
                          AppTextStyles.caption.copyWith(color: Colors.white38),
                    ),
                ],
              ),
            ),
            Text(
              '${player.score}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/brand/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
