import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../models/game_model.dart';
import '../sources/chess_com_api.dart';

/// Repository for game history data from Chess.com.
class GameRepository {
  GameRepository(this._chessCom, this._storage);

  final ChessComApi _chessCom;
  final StorageService _storage;

  // In-memory cache
  final Map<String, List<GameModel>> _gamesCache = {};

  /// Fetch recent games for a user.
  Future<List<GameModel>> getRecentGames(
    String username, {
    bool forceRefresh = false,
  }) async {
    final key = username.toLowerCase();

    if (!forceRefresh && _gamesCache.containsKey(key)) {
      return _gamesCache[key]!;
    }

    try {
      final archives = await _chessCom.getArchiveUrls(username);

      final List<String> targets = [];

      // 1. Start with reliable archives from Chess.com
      if (archives.isNotEmpty) {
        final sortedArchives = List<String>.from(archives)
          ..sort((a, b) => b.compareTo(a));
        targets.addAll(sortedArchives.take(15)); // Fetch up to 15 months
      }

      // 2. Proactively add current month in case archives list is stale
      final now = DateTime.now();
      final currentMonthUrl =
          'https://api.chess.com/pub/player/${username.toLowerCase()}/games/${now.year}/${now.month.toString().padLeft(2, '0')}';

      if (!targets.contains(currentMonthUrl)) {
        targets.insert(0, currentMonthUrl);
      }

      final results = await Future.wait(targets
          .toSet()
          .map((url) => _chessCom.getGamesFromArchive(url).catchError((e) {
                debugPrint('Archive fetch fail for $url: $e');
                return <GameModel>[];
              })));

      final List<GameModel> allGames = [];
      final Set<String> seenIds = {};

      for (final games in results) {
        for (final g in games) {
          if (!seenIds.contains(g.id)) {
            allGames.add(g);
            seenIds.add(g.id);
          }
        }
      }

      // Sort by date descending
      allGames.sort((a, b) => b.endTime.compareTo(a.endTime));

      _gamesCache[key] = allGames;
      return allGames;
    } catch (e) {
      return _gamesCache[key] ?? [];
    }
  }

  void clearAll() => _gamesCache.clear();
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(
    ref.read(chessComApiProvider),
    ref.read(storageServiceProvider),
  );
});
