import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../models/game_model.dart';
import '../sources/chess_com_api.dart';
import '../sources/lichess_api.dart';

/// Repository for game history data.
class GameRepository {
  GameRepository(this._chessCom, this._lichess, this._storage);

  final ChessComApi _chessCom;
  final LichessApi _lichess;
  final StorageService _storage;

  // In-memory cache
  final Map<String, List<GameModel>> _gamesCache = {};

  /// Fetch recent games for a user.
  Future<List<GameModel>> getRecentGames(
    String username, {
    bool forceRefresh = false,
    String? platform,
  }) async {
    final effectivePlatform =
        platform ?? _storage.connectedPlatform ?? 'chess_com';
    final key = '${effectivePlatform}_${username.toLowerCase()}';

    if (!forceRefresh && _gamesCache.containsKey(key)) {
      return _gamesCache[key]!;
    }

    try {
      List<GameModel> allGames = [];

      if (effectivePlatform == 'lichess') {
        allGames = await _lichess.getRecentGames(username, limit: 30);
      } else {
        final archives = await _chessCom.getArchiveUrls(username);
        if (archives.isEmpty) return [];

        final recentArchives = archives.reversed.take(6).toList();
        final results = await Future.wait(recentArchives.map((url) => _chessCom
            .getGamesFromArchive(url)
            .catchError((_) => <GameModel>[])));

        for (final games in results) {
          allGames.addAll(games);
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
    ref.read(lichessApiProvider),
    ref.read(storageServiceProvider),
  );
});
