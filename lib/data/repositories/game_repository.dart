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
      if (archives.isNotEmpty) {
        targets.addAll(archives.reversed);
      }

      // Proactively fetch current month AND previous month to catch late updates
      final now = DateTime.now();
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;

      final currentMonthUrl =
          'https://api.chess.com/pub/player/${username.toLowerCase()}/games/${now.year}/${now.month.toString().padLeft(2, '0')}';
      final prevMonthUrl =
          'https://api.chess.com/pub/player/${username.toLowerCase()}/games/$lastMonthYear/${lastMonth.toString().padLeft(2, '0')}';

      if (!targets.contains(currentMonthUrl)) {
        targets.insert(0, currentMonthUrl);
      }
      if (!targets.contains(prevMonthUrl)) {
        targets.add(prevMonthUrl);
      }

      // Take a robust set of recent archives
      final limitedTargets = targets.toSet().take(12).toList();

      final results = await Future.wait(limitedTargets.map((url) =>
          _chessCom.getGamesFromArchive(url).catchError((_) => <GameModel>[])));

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
