import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/storage_service.dart';
import '../../engine/opening_book.dart';
import '../review/board/board_state.dart';
import '../review/board/chess_board_widget.dart';

final _openingSearchProvider = StateProvider<String>((ref) => '');

final _filteredOpeningsProvider =
    Provider<List<(String fen, String eco, String name, String pgn)>>((ref) {
  final search = ref.watch(_openingSearchProvider).toLowerCase();
  final all = OpeningBook.allOpenings.entries
      .map((e) => (e.key, e.value.$1, e.value.$2, e.value.$3))
      .toList();

  if (search.isEmpty) return all;

  return all.where((o) {
    return o.$2.toLowerCase().contains(search) ||
        o.$3.toLowerCase().contains(search);
  }).toList();
});

class OpeningExplorerScreen extends ConsumerWidget {
  const OpeningExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openings = ref.watch(_filteredOpeningsProvider);
    final storage = ref.watch(storageServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text('Opening Explorer', style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) =>
                  ref.read(_openingSearchProvider.notifier).state = val,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search opening name or ECO...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.backgroundSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${openings.length} OPENINGS FOUND',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: openings.length,
              itemBuilder: (context, index) {
                final opening = openings[index];
                return _OpeningCard(
                  fen: opening.$1,
                  eco: opening.$2,
                  name: opening.$3,
                  pgn: opening.$4,
                  pieceSetId: storage.pieceSet,
                  boardThemeId: storage.boardTheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningCard extends StatelessWidget {
  const _OpeningCard({
    required this.fen,
    required this.eco,
    required this.name,
    required this.pgn,
    required this.pieceSetId,
    required this.boardThemeId,
  });

  final String fen;
  final String eco;
  final String name;
  final String pgn;
  final String pieceSetId;
  final String boardThemeId;

  @override
  Widget build(BuildContext context) {
    // Build board state from FEN
    // Note: BoardStateBuilder.fromFen is fast enough for the small preview boards.
    final boardState = BoardStateBuilder.fromFen(fen);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small Chess Board
          SizedBox(
            width: 100,
            height: 100,
            child: ChessBoardWidget(
              boardState: boardState,
              pieceSetId: pieceSetId,
              boardThemeId: boardThemeId,
              showCoordinates: false,
              highlightLastMove: false,
              animate: false,
            ),
          ),

          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    eco,
                    style: AppTextStyles.monoSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  pgn,
                  style: AppTextStyles.monoSmall.copyWith(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
