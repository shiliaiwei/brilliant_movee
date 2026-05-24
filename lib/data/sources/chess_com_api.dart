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
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.chess.com/pub',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 StupidBrilliant/1.2',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Simple retry for 429 Rate Limit or transient errors
          if (error.response?.statusCode == 429 ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            // Wait a bit before retrying if rate limited
            if (error.response?.statusCode == 429) {
              await Future.delayed(const Duration(seconds: 2));
            }

            try {
              final response = await dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Fetch player profile.
  Future<PlayerModel> getPlayer(String username) async {
    final response = await _dio.get('/player/${username.toLowerCase()}');
    return PlayerModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch player stats (ratings).
  Future<PlayerStats> getPlayerStats(String username) async {
    final response = await _dio.get('/player/${username.toLowerCase()}/stats');
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

  /// Fetch Leaderboards
  Future<Map<String, dynamic>> getLeaderboards() async {
    final response = await _dio.get('/leaderboards');
    return response.data as Map<String, dynamic>;
  }
}

final chessComApiProvider = Provider<ChessComApi>((ref) => ChessComApi());
