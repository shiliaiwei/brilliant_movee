import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_badge.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/player_model.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/game_repository.dart';

final _homePlayerProvider =
    FutureProvider.autoDispose<PlayerModel?>((ref) async {
  final username = ref.read(storageServiceProvider).connectedUsername;
  if (username == null) return null;
  return ref.read(playerRepositoryProvider).getFullProfile(username);
});

final _homeGamesProvider =
    FutureProvider.autoDispose<List<GameModel>>((ref) async {
  final username = ref.read(storageServiceProvider).connectedUsername;
  if (username == null) return [];
  return ref.read(gameRepositoryProvider).getRecentGames(username);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.read(storageServiceProvider).connectedUsername;
    final playerAsync = ref.watch(_homePlayerProvider);
    final gamesAsync = ref.watch(_homeGamesProvider);

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.heroGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenPadding,
              vertical: AppSpacing.screenV,
            ),
            child: ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting header with Logo
                  Row(
                    children: [
                      _BrandLogo(),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _GreetingHeader(
                          username: username,
                          playerAsync: playerAsync,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // On wide screens: two-column layout
                  if (context.isWide)
                    _WideHomeLayout(
                      username: username,
                      gamesAsync: gamesAsync,
                    )
                  else
                    _NarrowHomeLayout(
                      username: username,
                      gamesAsync: gamesAsync,
                    ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.username,
    required this.playerAsync,
  });

  final String username;
  final AsyncValue<PlayerModel?> playerAsync;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: AppTextStyles.bodyMuted,
              ),
              Text(
                username,
                style: AppTextStyles.headline,
              ),
            ],
          ),
        ),
        // Avatar chip
        playerAsync.when(
          loading: () =>
              const ShimmerBox(width: 44, height: 44, borderRadius: 22),
          error: (_, __) => const _DefaultAvatar(),
          data: (player) => player?.avatar != null
              ? Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: player!.avatar!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _DefaultAvatar(),
                    ),
                  ),
                )
              : const _DefaultAvatar(),
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundElevated,
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: const Icon(Icons.person_rounded,
          color: AppColors.textSecondary, size: 22),
    );
  }
}

class _LastGameCard extends StatelessWidget {
  const _LastGameCard({required this.game, required this.username});

  final GameModel game;
  final String username;

  @override
  Widget build(BuildContext context) {
    final result = game.resultFor(username);
    final opponent = game.whiteUsername.toLowerCase() == username.toLowerCase()
        ? game.blackUsername
        : game.whiteUsername;
    final accuracy = game.accuracyFor(username);

    return ChtCard(
      onTap: () => context.push(
        AppRoutes.review,
        extra: game.pgn,
      ),
      glowColor: result == '1-0'
          ? AppColors.win
          : result == '0-1'
              ? AppColors.loss
              : AppColors.draw,
      child: Row(
        children: [
          // Mini board placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: const Icon(
              Icons.grid_on_rounded,
              color: AppColors.textSecondary,
              size: 28,
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
                        '${accuracy.toStringAsFixed(1)}% accuracy',
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
          ),
        ],
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

class _LastGameError extends StatelessWidget {
  const _LastGameError();

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      borderColor: AppColors.error.withValues(alpha: 0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text('Failed to load games', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _StatsTiles extends StatelessWidget {
  const _StatsTiles({required this.games, required this.username});

  final List<GameModel> games;
  final String username;

  @override
  Widget build(BuildContext context) {
    int wins = 0, total = games.length;
    double totalAccuracy = 0;
    int accuracyCount = 0;

    for (final g in games) {
      final r = g.resultFor(username);
      if (r == '1-0' && g.whiteUsername.toLowerCase() == username.toLowerCase())
        wins++;
      if (r == '0-1' && g.blackUsername.toLowerCase() == username.toLowerCase())
        wins++;
      final acc = g.accuracyFor(username);
      if (acc != null) {
        totalAccuracy += acc;
        accuracyCount++;
      }
    }

    final winRate = total > 0 ? (wins / total * 100).toStringAsFixed(1) : '-';
    final avgAccuracy = accuracyCount > 0
        ? (totalAccuracy / accuracyCount).toStringAsFixed(1)
        : '-';

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Win Rate',
            value: total > 0 ? '$winRate%' : '-',
            icon: Icons.emoji_events_rounded,
            color: AppColors.win,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Avg Accuracy',
            value: accuracyCount > 0 ? '$avgAccuracy%' : '-',
            icon: Icons.analytics_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Games',
            value: '$total',
            icon: Icons.history_rounded,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return ChtShimmer(
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
              child: const ShimmerBox(width: null, height: 80),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Responsive layout helpers ─────────────────────────────────────────────────

/// Mobile: single column stack
class _NarrowHomeLayout extends StatelessWidget {
  const _NarrowHomeLayout({
    required this.username,
    required this.gamesAsync,
  });

  final String username;
  final AsyncValue<List<GameModel>> gamesAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last Game', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        gamesAsync.when(
          loading: () => const GameCardShimmer(),
          error: (_, __) => const _LastGameError(),
          data: (games) => games.isEmpty
              ? _NoGamesCard(username: username)
              : _LastGameCard(game: games.first, username: username),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Your Stats', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        gamesAsync.when(
          loading: () => const _StatsShimmer(),
          error: (_, __) => const SizedBox.shrink(),
          data: (games) => _StatsTiles(games: games, username: username),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        ChtButton(
          label: 'Analyze New Game',
          onPressed: () => context.push(AppRoutes.history),
          icon: Icons.analytics_rounded,
        ),
      ],
    );
  }
}

/// Tablet/Desktop: two-column layout
class _WideHomeLayout extends StatelessWidget {
  const _WideHomeLayout({
    required this.username,
    required this.gamesAsync,
  });

  final String username;
  final AsyncValue<List<GameModel>> gamesAsync;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — last game + recent games list
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Game', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              gamesAsync.when(
                loading: () => const GameCardShimmer(),
                error: (_, __) => const _LastGameError(),
                data: (games) => games.isEmpty
                    ? _NoGamesCard(username: username)
                    : _LastGameCard(game: games.first, username: username),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Recent games list (up to 5)
              gamesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (games) {
                  if (games.length <= 1) return const SizedBox.shrink();
                  final recent = games.skip(1).take(4).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Games', style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.md),
                      ...recent.map((g) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _LastGameCard(game: g, username: username),
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.xxl),

        // Right column — stats + CTA
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Stats', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              gamesAsync.when(
                loading: () => const _StatsShimmer(),
                error: (_, __) => const SizedBox.shrink(),
                data: (games) => _StatsColumn(games: games, username: username),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ChtButton(
                label: 'Analyze New Game',
                onPressed: () => context.push(AppRoutes.history),
                icon: Icons.analytics_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vertical stats layout for wide screens (stacked instead of row)
class _StatsColumn extends StatelessWidget {
  const _StatsColumn({required this.games, required this.username});

  final List<GameModel> games;
  final String username;

  @override
  Widget build(BuildContext context) {
    int wins = 0;
    final total = games.length;
    double totalAccuracy = 0;
    int accuracyCount = 0;

    for (final g in games) {
      final r = g.resultFor(username);
      if ((r == '1-0' &&
              g.whiteUsername.toLowerCase() == username.toLowerCase()) ||
          (r == '0-1' &&
              g.blackUsername.toLowerCase() == username.toLowerCase())) {
        wins++;
      }
      final acc = g.accuracyFor(username);
      if (acc != null) {
        totalAccuracy += acc;
        accuracyCount++;
      }
    }

    final winRate = total > 0 ? (wins / total * 100).toStringAsFixed(1) : '-';
    final avgAccuracy = accuracyCount > 0
        ? (totalAccuracy / accuracyCount).toStringAsFixed(1)
        : '-';

    return Column(
      children: [
        _StatTile(
          label: 'Win Rate',
          value: total > 0 ? '$winRate%' : '-',
          icon: Icons.emoji_events_rounded,
          color: AppColors.win,
        ),
        const SizedBox(height: AppSpacing.sm),
        _StatTile(
          label: 'Avg Accuracy',
          value: accuracyCount > 0 ? '$avgAccuracy%' : '-',
          icon: Icons.analytics_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _StatTile(
          label: 'Games Analyzed',
          value: '$total',
          icon: Icons.history_rounded,
          color: AppColors.secondary,
        ),
      ],
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
