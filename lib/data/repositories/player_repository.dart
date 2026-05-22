import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../sources/chess_com_api.dart';

/// Repository for player data. Screens never call the API directly.
class PlayerRepository {
  PlayerRepository(this._api);

  final ChessComApi _api;

  // In-memory cache
  final Map<String, PlayerModel> _profileCache = {};

  /// Fetch full player profile with stats.
  /// Retries up to 3 times with exponential backoff on timeout.
  Future<PlayerModel> getFullProfile(String username) async {
    final key = username.toLowerCase();
    if (_profileCache.containsKey(key)) return _profileCache[key]!;

    PlayerModel? profile;
    int attempt = 0;
    const maxAttempts = 3;

    while (attempt < maxAttempts) {
      try {
        profile = await _api.getPlayer(username);
        final stats = await _api.getPlayerStats(username);
        profile = profile.copyWith(stats: stats);
        _profileCache[key] = profile;
        return profile;
      } on DioException catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          await Future.delayed(Duration(seconds: attempt * 2));
        } else {
          rethrow;
        }
      }
    }

    throw Exception('Failed to fetch profile after $maxAttempts attempts');
  }

  /// Validate username with retry.
  Future<bool> validateUsername(String username) async {
    int attempt = 0;
    const maxAttempts = 3;

    while (attempt < maxAttempts) {
      try {
        return await _api.validateUsername(username);
      } on DioException catch (e) {
        attempt++;
        if (attempt >= maxAttempts) return false;
        if (e.type == DioExceptionType.connectionTimeout) {
          await Future.delayed(Duration(seconds: attempt * 2));
        } else {
          return false;
        }
      }
    }
    return false;
  }

  void clearCache() => _profileCache.clear();
}

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.read(chessComApiProvider));
});
