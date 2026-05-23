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
import '../../data/repositories/player_repository.dart';

final _leaderboardCategoryProvider =
    StateProvider<String>((ref) => 'chess_rapid');

final _leaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardPlayer>>((ref) async {
  final category = ref.watch(_leaderboardCategoryProvider);
  return ref.read(playerRepositoryProvider).getTopPlayers(category);
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
    final leaderboardAsync = ref.watch(_leaderboardProvider);
    final selectedCategory = ref.watch(_leaderboardCategoryProvider);

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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearch,
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

            // Category filters
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  'chess_rapid',
                  'chess_blitz',
                  'chess_bullet',
                  'daily',
                  'daily_puzzle'
                ]
                    .map((cat) => _FilterChip(
                          label: cat
                              .replaceAll('chess_', '')
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          isSelected: selectedCategory == cat,
                          onTap: () => ref
                              .read(_leaderboardCategoryProvider.notifier)
                              .state = cat,
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('TOP PLAYERS',
                    style:
                        AppTextStyles.badge.copyWith(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: leaderboardAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => const Center(
                    child: Text('Failed to load leaderboard',
                        style: TextStyle(color: Colors.white38))),
                data: (players) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: players.length,
                    itemBuilder: (context, i) {
                      final p = players[i];
                      // Highlight connected user if found
                      final isMe =
                          p.username.toLowerCase() == username.toLowerCase();
                      return _LeaderboardItem(player: p, isMe: isMe);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
  const _LeaderboardItem({required this.player, this.isMe = false});
  final LeaderboardPlayer player;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChtCard(
        onTap: () =>
            context.push('${AppRoutes.profile}?username=${player.username}'),
        padding: const EdgeInsets.all(12),
        glowColor: isMe ? AppColors.primary : null,
        borderColor: isMe ? AppColors.primary.withValues(alpha: 0.5) : null,
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '#${player.rank}',
                style: AppTextStyles.monoSmall.copyWith(
                  color: isMe
                      ? AppColors.primary
                      : (player.rank <= 3
                          ? AppColors.brilliant
                          : Colors.white38),
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
