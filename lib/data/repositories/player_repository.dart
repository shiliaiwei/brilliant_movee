import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../models/player_model.dart';
import '../sources/chess_com_api.dart';
import '../sources/lichess_api.dart';

/// Repository for player data.
class PlayerRepository {
  PlayerRepository(this._chessCom, this._lichess, this._storage);

  final ChessComApi _chessCom;
  final LichessApi _lichess;
  final StorageService _storage;

  // In-memory cache
  final Map<String, PlayerModel> _profileCache = {};

  /// Fetch full player profile.
  Future<PlayerModel> getFullProfile(String username,
      {String? platform}) async {
    final effectivePlatform =
        platform ?? _storage.connectedPlatform ?? 'chess_com';
    final key = '${effectivePlatform}_${username.toLowerCase()}';
    if (_profileCache.containsKey(key)) return _profileCache[key]!;

    PlayerModel? profile;

    if (effectivePlatform == 'lichess') {
      profile = await _lichess.getPlayer(username);
    } else {
      profile = await _chessCom.getPlayer(username);
      final stats = await _chessCom.getPlayerStats(username);
      profile = profile.copyWith(stats: stats);
    }

    _profileCache[key] = profile;
    return profile;
  }

  /// Validate username exists on platform.
  Future<bool> validateUsername(String username,
      {String platform = 'chess_com'}) async {
    try {
      if (platform == 'lichess') {
        return await _lichess.validateUsername(username);
      }
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
    ref.read(lichessApiProvider),
    ref.read(storageServiceProvider),
  );
});
