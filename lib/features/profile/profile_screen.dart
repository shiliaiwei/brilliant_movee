import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_badge.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/shimmer_loader.dart';
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
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const _ProfileShimmer(),
        error: (e, _) => ChtErrorState(
          title: 'Failed to load profile',
          description:
              'Could not fetch data for "$username". Check your connection.',
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: AppSpacing.screenV,
      ),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroSection(player: player),
            const SizedBox(height: AppSpacing.xxl),
            if (player.stats != null) ...[
              Text('Rating Overview', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              _RatingsGrid(stats: player.stats!),
              const SizedBox(height: AppSpacing.xxl),
              Text('Performance Record', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              _WinLossSection(stats: player.stats!),
              const SizedBox(height: AppSpacing.xxl),
            ],
            Text('Analysis Stats', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            _AnalysisStatsGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppColors.divider, width: 2),
            ),
            child: ClipOval(
              child: player.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: player.avatar!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
                    )
                  : const _AvatarPlaceholder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(player.displayName, style: AppTextStyles.headline),
          Text(
            '@${player.username}',
            style: AppTextStyles.bodyMuted.copyWith(letterSpacing: 1),
          ),
          if (player.country != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ChtBadge(
              label: player.country!.toUpperCase(),
              color: AppColors.textSecondary,
              compact: true,
            ),
          ],
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
      color: AppColors.backgroundSurface,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.textDisabled,
        size: 48,
      ),
    );
  }
}

class _RatingsGrid extends StatelessWidget {
  const _RatingsGrid({required this.stats});
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final List<(String, int?)> ratings = [
      ('Rapid', stats.rapidRating),
      ('Blitz', stats.blitzRating),
      ('Bullet', stats.bulletRating),
      ('Daily', stats.dailyRating),
    ];

    final visibleRatings =
        ratings.where((r) => r.$2 != null && r.$2! > 0).toList();

    if (visibleRatings.isEmpty) {
      return Text('No ratings available', style: AppTextStyles.bodyMuted);
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: visibleRatings
          .map((r) => SizedBox(
                width: (MediaQuery.of(context).size.width -
                        context.screenPadding * 2 -
                        AppSpacing.md) /
                    2,
                child: ChtRatingBadge(category: r.$1, rating: r.$2!),
              ))
          .toList(),
    );
  }
}

class _WinLossSection extends StatelessWidget {
  const _WinLossSection({required this.stats});
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalGames;
    if (total == 0) return const SizedBox.shrink();

    return ChtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _ResultIndicator(
                  label: 'W', value: stats.wins, color: AppColors.win),
              const SizedBox(width: AppSpacing.md),
              _ResultIndicator(
                  label: 'D', value: stats.draws, color: AppColors.draw),
              const SizedBox(width: AppSpacing.md),
              _ResultIndicator(
                  label: 'L', value: stats.losses, color: AppColors.loss),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                      flex: stats.wins, child: Container(color: AppColors.win)),
                  Expanded(
                      flex: stats.draws,
                      child: Container(color: AppColors.draw)),
                  Expanded(
                      flex: stats.losses,
                      child: Container(color: AppColors.loss)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Games: $total', style: AppTextStyles.caption),
              Text(
                'Win Rate: ${(stats.winRate * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.win, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultIndicator extends StatelessWidget {
  const _ResultIndicator(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.bold)),
        Text('$value', style: AppTextStyles.title.copyWith(fontSize: 18)),
      ],
    );
  }
}

class _AnalysisStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _AnalysisStatTile(
            label: 'Brilliant',
            value: '12',
            color: AppColors.brilliant,
            icon: Icons.auto_awesome),
        _AnalysisStatTile(
            label: 'Great',
            value: '45',
            color: AppColors.great,
            icon: Icons.thumb_up_rounded),
        _AnalysisStatTile(
            label: 'Accuracy',
            value: '82%',
            color: AppColors.primary,
            icon: Icons.analytics_rounded),
        _AnalysisStatTile(
            label: 'Games',
            value: '128',
            color: AppColors.secondary,
            icon: Icons.history_rounded),
      ],
    );
  }
}

class _AnalysisStatTile extends StatelessWidget {
  const _AnalysisStatTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width -
              context.screenPadding * 2 -
              AppSpacing.md) /
          2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headline.copyWith(fontSize: 22)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const ChtShimmer(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            ShimmerBox(width: 100, height: 100, borderRadius: 50),
            SizedBox(height: 16),
            ShimmerBox(width: 150, height: 24),
            SizedBox(height: 8),
            ShimmerBox(width: 100, height: 16),
            SizedBox(height: 40),
            ShimmerBox(width: double.infinity, height: 200),
          ],
        ),
      ),
    );
  }
}
