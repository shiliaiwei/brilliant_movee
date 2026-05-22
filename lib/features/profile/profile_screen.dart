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
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';

final _profileProvider = FutureProvider.autoDispose
    .family<PlayerModel, String>((ref, username) async {
  return ref.read(playerRepositoryProvider).getFullProfile(username);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_profileProvider(username));

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(username),
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const _ProfileShimmer(),
        error: (e, _) => ChtErrorState(
          title: 'Failed to load profile',
          description: 'Could not fetch data for "$username". Check your connection.',
          onRetry: () => ref.invalidate(_profileProvider(username)),
        ),
        data: (player) => _ProfileContent(player: player),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: context.screenPadding,
            right: context.screenPadding,
            top: AppSpacing.screenV,
            bottom: 100,
          ),
          child: ResponsiveContainer(
            child: context.isWide
                ? _WideProfileLayout(player: player)
                : _NarrowProfileLayout(player: player),
          ),
        ),

        // Pinned CTA button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              context.screenPadding,
              AppSpacing.md,
              context.screenPadding,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundDeep.withValues(alpha: 0),
                  AppColors.backgroundDeep,
                ],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ChtButton(
                  label: 'View Game History',
                  onPressed: () => context.go(AppRoutes.history),
                  icon: Icons.history_rounded,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return ChtCard(
      glowColor: AppColors.primary,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipOval(
              child: player.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: player.avatar!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const _AvatarPlaceholder(),
                      errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
                    )
                  : const _AvatarPlaceholder(),
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.displayName, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '@${player.username}',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (player.country != null) ...[
                      ChtBadge(
                        label: player.country!.toUpperCase(),
                        color: AppColors.book,
                        compact: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (player.joinedYear.isNotEmpty)
                      Text(
                        'Since ${player.joinedYear}',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundElevated,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.textSecondary,
        size: 36,
      ),
    );
  }
}

class _RatingsRow extends StatelessWidget {
  const _RatingsRow({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChtRatingBadge(
            category: 'Rapid',
            rating: stats.rapidRating ?? 0,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ChtRatingBadge(
            category: 'Blitz',
            rating: stats.blitzRating ?? 0,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ChtRatingBadge(
            category: 'Bullet',
            rating: stats.bulletRating ?? 0,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ChtRatingBadge(
            category: 'Daily',
            rating: stats.dailyRating ?? 0,
          ),
        ),
      ],
    );
  }
}

class _WinLossBar extends StatelessWidget {
  const _WinLossBar({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalGames;
    if (total == 0) {
      return Text('No games recorded', style: AppTextStyles.bodyMuted);
    }

    final winFrac = stats.wins / total;
    final drawFrac = stats.draws / total;
    final lossFrac = stats.losses / total;

    return ChtCard(
      child: Column(
        children: [
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Flexible(
                    flex: (winFrac * 100).round(),
                    child: Container(color: AppColors.win),
                  ),
                  Flexible(
                    flex: (drawFrac * 100).round(),
                    child: Container(color: AppColors.draw),
                  ),
                  Flexible(
                    flex: (lossFrac * 100).round(),
                    child: Container(color: AppColors.loss),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatLabel(
                label: 'Wins',
                value: '${stats.wins}',
                color: AppColors.win,
              ),
              _StatLabel(
                label: 'Draws',
                value: '${stats.draws}',
                color: AppColors.draw,
              ),
              _StatLabel(
                label: 'Losses',
                value: '${stats.losses}',
                color: AppColors.loss,
              ),
              _StatLabel(
                label: 'Win Rate',
                value: '${(stats.winRate * 100).toStringAsFixed(1)}%',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChtCard(
            child: Column(
              children: [
                const Icon(Icons.people_rounded,
                    color: AppColors.primary, size: 24),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${player.followers}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Followers', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ChtCard(
            child: Column(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.secondary, size: 24),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  player.joinedYear.isNotEmpty ? player.joinedYear : '-',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Joined', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ChtShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          children: [
            const ShimmerBox(width: double.infinity, height: 100),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i < 3 ? AppSpacing.sm : 0),
                    child: const ShimmerBox(width: null, height: 70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const ShimmerBox(width: double.infinity, height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Responsive profile layouts ────────────────────────────────────────────────

class _NarrowProfileLayout extends StatelessWidget {
  const _NarrowProfileLayout({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(player: player),
        const SizedBox(height: AppSpacing.xl),
        if (player.stats != null) ...[
          Text('Ratings', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          _RatingsRow(stats: player.stats!),
          const SizedBox(height: AppSpacing.xl),
          Text('Record', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          _WinLossBar(stats: player.stats!),
          const SizedBox(height: AppSpacing.xl),
        ],
        Text('Quick Stats', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        _QuickStats(player: player),
      ],
    );
  }
}

class _WideProfileLayout extends StatelessWidget {
  const _WideProfileLayout({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: hero card + quick stats
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroCard(player: player),
              const SizedBox(height: AppSpacing.xl),
              Text('Quick Stats', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              _QuickStats(player: player),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        // Right: ratings + record
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (player.stats != null) ...[
                Text('Ratings', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                _RatingsRow(stats: player.stats!),
                const SizedBox(height: AppSpacing.xl),
                Text('Record', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                _WinLossBar(stats: player.stats!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
