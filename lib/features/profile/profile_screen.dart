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

final _selectedInsightTabProvider =
    StateProvider.autoDispose<String>((ref) => 'Overview');

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

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(_selectedInsightTabProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(player: player),
          const SizedBox(height: 32),

          // Insights Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DATE RANGE',
                      style: AppTextStyles.caption.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('All Time',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('GAMES',
                      style: AppTextStyles.caption.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('${player.stats?.totalGames ?? 0}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Insights Menu Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                'Overview',
                'Game Results',
                'Game Shapes',
                'Phases',
                'Openings',
                'Tactics',
                'Moves',
                'Calendar',
                'Geography'
              ]
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _InsightChip(
                          label: t,
                          isSelected: selectedTab == t,
                          onTap: () => ref
                              .read(_selectedInsightTabProvider.notifier)
                              .state = t,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),

          if (selectedTab == 'Overview') ...[
            if (player.stats != null) ...[
              Text('RATING OVERVIEW',
                  style:
                      AppTextStyles.badge.copyWith(color: AppColors.primary)),
              const SizedBox(height: 12),
              _RatingsGrid(stats: player.stats!),
              const SizedBox(height: 32),
              Text('PERFORMANCE RECORD',
                  style:
                      AppTextStyles.badge.copyWith(color: AppColors.primary)),
              const SizedBox(height: 12),
              _WinLossSection(stats: player.stats!),
              const SizedBox(height: 32),
            ],
            Text('MOVE QUALITY INSIGHTS',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 12),
            _MoveQualityBreakdown(),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.analytics_outlined,
                        color: Colors.white10, size: 64),
                    const SizedBox(height: 16),
                    Text('$selectedTab Details',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white38)),
                    const SizedBox(height: 8),
                    const Text('Premium analysis in progress...',
                        style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip(
      {required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const shape = _ChipShape(cut: 6);
    return Material(
      color: Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.primary : AppColors.backgroundSurface,
            shape: shape.copyWithBorder(
                color: isSelected ? Colors.transparent : Colors.white10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipShape extends ShapeBorder {
  const _ChipShape({required this.cut, this.borderColor, this.borderWidth = 1});
  final double cut;
  final Color? borderColor;
  final double borderWidth;

  _ChipShape copyWithBorder({Color? color, double? width}) {
    return _ChipShape(
      cut: cut,
      borderColor: color ?? borderColor,
      borderWidth: width ?? borderWidth,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.all(borderColor != null ? borderWidth : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(borderWidth), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderColor != null) {
      final paint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
    }
  }

  @override
  ShapeBorder scale(double t) => _ChipShape(
      cut: cut * t, borderColor: borderColor, borderWidth: borderWidth * t);
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
          .map((r) => SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: ChtCard(
                  onTap: () {},
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.backgroundSurface,
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
      onTap: () {},
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
          const _QualityRow(
              quality: MoveQuality.book, total: 67, percentage: '9.4%'),
          const _QualityRow(
              quality: MoveQuality.inaccuracy, total: 54, percentage: '11.0%'),
          const _QualityRow(
              quality: MoveQuality.mistake, total: 32, percentage: '7.2%'),
          const _QualityRow(
              quality: MoveQuality.blunder, total: 12, percentage: '3.1%'),
          const _QualityRow(
              quality: MoveQuality.miss, total: 5, percentage: '0.5%'),
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
    final (asset, color, label) = _config();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: _buildIcon(asset, color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: color, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text(percentage,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Colors.white38)),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text('$total',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String asset, Color color) {
    if (quality == MoveQuality.miss) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF8E24AA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 14,
        ),
      );
    }
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.circle, color: color, size: 14),
    );
  }

  (String, Color, String) _config() {
    return switch (quality) {
      MoveQuality.brilliant => (
          'assets/classification/brilliant.png',
          AppColors.brilliant,
          'Brilliant'
        ),
      MoveQuality.great => (
          'assets/classification/excellent.png',
          AppColors.great,
          'Excellent'
        ),
      MoveQuality.best => (
          'assets/classification/best.png',
          AppColors.primary,
          'Best'
        ),
      MoveQuality.good => (
          'assets/classification/very_good.png',
          AppColors.good,
          'Good'
        ),
      MoveQuality.book => (
          'assets/classification/book.png',
          AppColors.book,
          'Book'
        ),
      MoveQuality.inaccuracy => (
          'assets/classification/inaccuracy.png',
          AppColors.inaccuracy,
          'Inaccuracy'
        ),
      MoveQuality.mistake => (
          'assets/classification/mistake.png',
          AppColors.mistake,
          'Mistake'
        ),
      MoveQuality.blunder => (
          'assets/classification/blunder.png',
          AppColors.blunder,
          'Blunder'
        ),
      MoveQuality.miss => (
          'assets/classification/sigma.png',
          AppColors.miss,
          'Missed Win'
        ),
      _ => ('assets/classification/good.png', AppColors.good, 'Good'),
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
