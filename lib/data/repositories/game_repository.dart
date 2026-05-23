import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../sources/chess_com_api.dart';

/// Repository for game history data.
class GameRepository {
  GameRepository(this._api);

  final ChessComApi _api;

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
      final archives = await _api.getArchiveUrls(username);
      if (archives.isEmpty) return [];

      // Fetch last 12 months for a complete history
      final recentArchives = archives.reversed.take(12).toList();

      // Use Future.wait for faster parallel fetching
      final results = await Future.wait(recentArchives.map((url) =>
          _api.getGamesFromArchive(url).catchError((_) => <GameModel>[])));

      final allGames = <GameModel>[];
      for (final games in results) {
        allGames.addAll(games);
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
  return GameRepository(ref.read(chessComApiProvider));
});
