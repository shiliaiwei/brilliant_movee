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
      if (archives.isEmpty) return [];

      // Fetch last 12 active months for history
      final recentArchives = archives.reversed.take(12).toList();

      final results = await Future.wait(recentArchives.map((url) =>
          _chessCom.getGamesFromArchive(url).catchError((_) => <GameModel>[])));

      final List<GameModel> allGames = [];
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
  return GameRepository(
    ref.read(chessComApiProvider),
    ref.read(storageServiceProvider),
  );
});
