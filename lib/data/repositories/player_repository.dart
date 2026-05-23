import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../models/player_model.dart';
import '../models/leaderboard_model.dart';
import '../sources/chess_com_api.dart';

/// Repository for player data.
class PlayerRepository {
  PlayerRepository(this._chessCom, this._storage);

  final ChessComApi _chessCom;
  final StorageService _storage;

  // In-memory cache
  final Map<String, PlayerModel> _profileCache = {};

  /// Fetch top players from Chess.com
  Future<List<LeaderboardPlayer>> getTopPlayers(String category) async {
    final data = await _chessCom.getLeaderboards();
    final players = data[category] as List? ?? [];
    return players
        .map((json) => LeaderboardPlayer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch full player profile from Chess.com
  Future<PlayerModel> getFullProfile(String username,
      {bool forceRefresh = false}) async {
    final key = username.toLowerCase();
    if (!forceRefresh && _profileCache.containsKey(key)) {
      return _profileCache[key]!;
    }

    try {
      final profile = await _chessCom.getPlayer(username);
      PlayerStats? stats;
      try {
        stats = await _chessCom.getPlayerStats(username);
      } catch (e) {
        // Stats might be missing for very new or restricted accounts
      }

      final completeProfile = profile.copyWith(stats: stats);
      _profileCache[key] = completeProfile;
      return completeProfile;
    } catch (e) {
      // If direct profile fetch fails, try to return whatever we have or rethrow
      rethrow;
    }
  }

  /// Validate username exists on Chess.com
  Future<bool> validateUsername(String username) async {
    try {
      return await _chessCom.validateUsername(username);
    } catch (_) {
      return false;
    }
  }

  void clearCache() => _profileCache.clear();
}

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(
    ref.read(chessComApiProvider),
    ref.read(storageServiceProvider),
  );
});
