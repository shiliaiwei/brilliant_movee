import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';

class BrilliantGamesScreen extends ConsumerWidget {
  const BrilliantGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final rawData = storage.brilliantGamesData;

    final games =
        rawData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    // Sort by timestamp if available
    games.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('BRILLIANT REPLAYS'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: games.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.textDisabled, size: 64),
                  const SizedBox(height: 24),
                  Text('NO BRILLIANT MOVES YET',
                      style: AppTextStyles.title
                          .copyWith(color: AppColors.textDisabled)),
                  const SizedBox(height: 8),
                  Text('Analyze games to find brilliant sacrifices!',
                      style: AppTextStyles.bodyMuted),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: games.length,
              itemBuilder: (context, i) {
                final game = games[i];
                final id = game['id'] as String;
                final pgn = game['pgn'] as String;
                final moveIndex = game['move'] as int;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChtCard(
                    onTap: () => context.push(
                        '${AppRoutes.review}?gameId=$id&move=$moveIndex',
                        extra: pgn),
                    borderColor: AppColors.brilliant.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.brilliant.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: AppColors.brilliant, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Brilliant Move Found',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: Colors.white)),
                              Text('Tap to replay the sequence',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_outline_rounded,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
