import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../sources/chess_com_api.dart';

/// Repository for game history data.
/// Fetches from Chess.com API and caches in memory.
class GameRepository {
  GameRepository(this._api);

  final ChessComApi _api;

  // In-memory cache: username -> list of games
  final Map<String, List<GameModel>> _gamesCache = {};
  final Map<String, List<String>> _archiveCache = {};

  /// Fetch recent games for a user (current + previous month).
  Future<List<GameModel>> getRecentGames(
    String username, {
    bool forceRefresh = false,
  }) async {
    final key = username.toLowerCase();

    if (!forceRefresh && _gamesCache.containsKey(key)) {
      return _gamesCache[key]!;
    }

    final archives = await _api.getArchiveUrls(username);
    _archiveCache[key] = archives;

    if (archives.isEmpty) return [];

    // Fetch last 6 months
    final recentArchives = archives.reversed.take(6).toList();
    final allGames = <GameModel>[];

    for (final archiveUrl in recentArchives) {
      try {
        final games = await _api.getGamesFromArchive(archiveUrl);
        allGames.addAll(games);
      } catch (_) {
        // Skip failed archive months
      }
    }

    // Sort by date descending
    allGames.sort((a, b) => b.endTime.compareTo(a.endTime));

    _gamesCache[key] = allGames;
    return allGames;
  }

  /// Get a specific game by ID from cache.
  GameModel? getGameById(String username, String gameId) {
    final key = username.toLowerCase();
    final games = _gamesCache[key] ?? [];
    try {
      return games.firstWhere((g) => g.id == gameId);
    } catch (_) {
      return null;
    }
  }

  /// Filter games by result.
  List<GameModel> filterGames(
    List<GameModel> games,
    String username, {
    String? resultFilter, // 'win', 'loss', 'draw', null = all
    TimeControl? timeControlFilter,
  }) {
    return games.where((game) {
      if (resultFilter != null) {
        final result = game.resultFor(username);
        final matches = switch (resultFilter) {
          'win' => result == '1-0' &&
                  game.whiteUsername.toLowerCase() == username.toLowerCase() ||
              result == '0-1' &&
                  game.blackUsername.toLowerCase() == username.toLowerCase(),
          'loss' => result == '0-1' &&
                  game.whiteUsername.toLowerCase() == username.toLowerCase() ||
              result == '1-0' &&
                  game.blackUsername.toLowerCase() == username.toLowerCase(),
          'draw' => result == '1/2-1/2',
          _ => true,
        };
        if (!matches) return false;
      }

      if (timeControlFilter != null && game.timeControl != timeControlFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void clearCache(String username) {
    _gamesCache.remove(username.toLowerCase());
  }

  void clearAll() {
    _gamesCache.clear();
    _archiveCache.clear();
  }
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.read(chessComApiProvider));
});
