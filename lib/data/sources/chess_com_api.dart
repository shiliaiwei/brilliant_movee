import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../models/game_model.dart';

/// Chess.com Public API client.
/// No auth key required. All screens access data through repositories.
class ChessComApi {
  ChessComApi() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://api.chess.com/pub',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent': 'BrilliantMovee/1.0 (chess analysis app)',
        },
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) {
            // Retry logic handled at repository level
            handler.next(error);
          },
        ),
      );
  }

  /// Fetch player profile.
  Future<PlayerModel> getPlayer(String username) async {
    final response = await _dio.get('/player/${username.toLowerCase()}');
    return PlayerModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch player stats (ratings).
  Future<PlayerStats> getPlayerStats(String username) async {
    final response =
        await _dio.get('/player/${username.toLowerCase()}/stats');
    return PlayerStats.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch list of monthly archive URLs.
  Future<List<String>> getArchiveUrls(String username) async {
    final response =
        await _dio.get('/player/${username.toLowerCase()}/games/archives');
    final data = response.data as Map<String, dynamic>;
    return List<String>.from(data['archives'] as List? ?? []);
  }

  /// Fetch games from a monthly archive URL.
  Future<List<GameModel>> getGamesFromArchive(String archiveUrl) async {
    final response = await _dio.get(archiveUrl);
    final data = response.data as Map<String, dynamic>;
    final games = data['games'] as List? ?? [];
    return games
        .map((g) => GameModel.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  /// Validate username exists (returns true if 200 OK).
  Future<bool> validateUsername(String username) async {
    try {
      await _dio.get('/player/${username.toLowerCase()}');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }
}

final chessComApiProvider = Provider<ChessComApi>((ref) => ChessComApi());
