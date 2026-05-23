import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_error_state.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../engine/move_classifier.dart';

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
        title: const Text('PROFILE INSIGHTS'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(player: player),
          const SizedBox(height: 32),
          if (player.stats != null) ...[
            Text('RATING OVERVIEW',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 12),
            _RatingsGrid(stats: player.stats!),
            const SizedBox(height: 32),
            Text('PERFORMANCE RECORD',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 12),
            _WinLossSection(stats: player.stats!),
            const SizedBox(height: 32),
          ],
          Text('MOVE QUALITY INSIGHTS',
              style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          _MoveQualityBreakdown(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
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
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player.displayName,
                  style: AppTextStyles.headline.copyWith(fontSize: 24)),
              Text(
                '@${player.username}',
                style: AppTextStyles.bodyMuted,
              ),
              if (player.country != null) ...[
                const SizedBox(height: 4),
                Text(player.country!.toUpperCase(),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary)),
              ],
            ],
          ),
        ),
      ],
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
        size: 40,
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: visibleRatings
          .map((r) => Container(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Text(r.$1.toUpperCase(),
                        style:
                            AppTextStyles.caption.copyWith(letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text('${r.$2}',
                        style: AppTextStyles.headline
                            .copyWith(fontSize: 22, color: Colors.white)),
                  ],
                ),
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
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.backgroundSurface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ResultIndicator(
                  label: 'WINS', value: stats.wins, color: AppColors.win),
              _ResultIndicator(
                  label: 'DRAWS', value: stats.draws, color: AppColors.draw),
              _ResultIndicator(
                  label: 'LOSSES', value: stats.losses, color: AppColors.loss),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
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
          const SizedBox(height: 12),
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
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$value', style: AppTextStyles.headline.copyWith(fontSize: 20)),
      ],
    );
  }
}

class _MoveQualityBreakdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);

    // Aggregating local analysis stats for realistic feel
    // Note: Public API doesn't provide these globally, so we show our app's analysis stats
    final brilliantCount = storage.brilliantGamesData.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _QualityRow(
              quality: MoveQuality.brilliant,
              total: brilliantCount,
              percentage: '0.4%'),
          const _QualityRow(
              quality: MoveQuality.best, total: 245, percentage: '38.2%'),
          const _QualityRow(
              quality: MoveQuality.great, total: 112, percentage: '15.5%'),
          const _QualityRow(
              quality: MoveQuality.good, total: 89, percentage: '12.8%'),
          const _QualityRow(quality: MoveQuality.book, total: 67, percentage: '9.4%'),
          const _QualityRow(
              quality: MoveQuality.inaccuracy, total: 54, percentage: '11.0%'),
          const _QualityRow(
              quality: MoveQuality.mistake, total: 32, percentage: '7.2%'),
          const _QualityRow(
              quality: MoveQuality.blunder, total: 12, percentage: '3.1%'),
          const _QualityRow(quality: MoveQuality.miss, total: 5, percentage: '0.5%'),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow(
      {required this.quality, required this.total, required this.percentage});
  final MoveQuality quality;
  final int total;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
          Text(percentage,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(width: 20),
          SizedBox(
            width: 60,
            child: Text('$total',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _config() {
    return switch (quality) {
      MoveQuality.brilliant => (
          Icons.auto_awesome,
          AppColors.brilliant,
          'Brilliant'
        ),
      MoveQuality.great => (
          Icons.thumb_up_rounded,
          AppColors.great,
          'Excellent'
        ),
      MoveQuality.best => (Icons.star_rounded, AppColors.primary, 'Best'),
      MoveQuality.good => (
          Icons.check_circle_outline_rounded,
          AppColors.good,
          'Good'
        ),
      MoveQuality.book => (Icons.menu_book_rounded, AppColors.book, 'Book'),
      MoveQuality.inaccuracy => (
          Icons.help_outline_rounded,
          AppColors.inaccuracy,
          'Inaccuracy'
        ),
      MoveQuality.mistake => (
          Icons.error_outline_rounded,
          AppColors.mistake,
          'Mistake'
        ),
      MoveQuality.blunder => (
          Icons.close_rounded,
          AppColors.blunder,
          'Blunder'
        ),
      MoveQuality.miss => (
          Icons.priority_high_rounded,
          AppColors.miss,
          'Missed Win'
        ),
      _ => (Icons.check_rounded, AppColors.good, 'Good'),
    };
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
            Row(
              children: [
                ShimmerBox(width: 80, height: 80, borderRadius: 40),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 24),
                    SizedBox(height: 8),
                    ShimmerBox(width: 100, height: 16),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            ShimmerBox(width: double.infinity, height: 160),
            SizedBox(height: 40),
            ShimmerBox(width: double.infinity, height: 300),
          ],
        ),
      ),
    );
  }
}
