import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../models/game_model.dart';

/// Lichess Public API client.
class LichessApi {
  LichessApi() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://lichess.org/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'StupidBrilliant/1.1 (+https://github.com/shiliaiwei/brilliant_movee)',
        },
      ),
    );
  }

  /// Fetch player profile.
  Future<PlayerModel> getPlayer(String username) async {
    final response = await _dio.get('/user/$username');
    final data = response.data as Map<String, dynamic>;

    final perfs = data['perfs'] as Map<String, dynamic>? ?? {};
    final count = data['count'] as Map<String, dynamic>? ?? {};

    return PlayerModel(
      username: data['username'] as String? ?? username,
      name: (data['profile'] as Map?)?['firstName'] as String?,
      avatar: null,
      country: (data['profile'] as Map?)?['country'] as String?,
      joined: (data['createdAt'] as int?) != null
          ? (data['createdAt']! ~/ 1000)
          : null,
      lastOnline:
          (data['seenAt'] as int?) != null ? (data['seenAt']! ~/ 1000) : null,
      followers: data['followers'] as int? ?? 0,
      stats: PlayerStats(
        rapidRating: (perfs['rapid'] as Map?)?['rating'] as int?,
        blitzRating: (perfs['blitz'] as Map?)?['rating'] as int?,
        bulletRating: (perfs['bullet'] as Map?)?['rating'] as int?,
        dailyRating: (perfs['correspondence'] as Map?)?['rating'] as int?,
        wins: count['win'] as int? ?? 0,
        losses: count['loss'] as int? ?? 0,
        draws: count['draw'] as int? ?? 0,
      ),
    );
  }

  /// Validate username exists.
  Future<bool> validateUsername(String username) async {
    try {
      await _dio.get('/user/$username');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  /// Fetch recent games.
  Future<List<GameModel>> getRecentGames(String username,
      {int limit = 20}) async {
    final response = await _dio.get(
      '/games/user/$username',
      queryParameters: {
        'max': limit,
        'pgnInJson': true,
        'clocks': false,
        'accuracy': false,
        'opening': true,
      },
      options: Options(responseType: ResponseType.plain),
    );

    return _parseNdJson(response.data as String);
  }

  List<GameModel> _parseNdJson(String ndjson) {
    final List<GameModel> games = [];
    final lines = ndjson.split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;

        final players = json['players'] as Map<String, dynamic>? ?? {};
        final white = players['white'] as Map<String, dynamic>? ?? {};
        final black = players['black'] as Map<String, dynamic>? ?? {};

        final winner = json['winner'] as String?;

        games.add(GameModel(
          id: json['id'] as String? ?? '',
          url: 'https://lichess.org/${json['id']}',
          pgn: json['pgn'] as String? ?? '',
          timeControl: _parseLichessSpeed(json['speed'] as String?),
          endTime: (json['lastMoveAt'] as int? ?? 0) ~/ 1000,
          whiteUsername:
              (white['user'] as Map?)?['name'] as String? ?? 'Anonymous',
          blackUsername:
              (black['user'] as Map?)?['name'] as String? ?? 'Anonymous',
          whiteRating: white['rating'] as int? ?? 0,
          blackRating: black['rating'] as int? ?? 0,
          result: winner == 'white'
              ? '1-0'
              : (winner == 'black' ? '0-1' : '1/2-1/2'),
          whiteResult:
              winner == 'white' ? 'win' : (winner == 'black' ? 'loss' : 'draw'),
          blackResult:
              winner == 'black' ? 'win' : (winner == 'white' ? 'loss' : 'draw'),
          openingName: (json['opening'] as Map?)?['name'] as String?,
          openingEco: (json['opening'] as Map?)?['eco'] as String?,
        ));
      } catch (e) {
        // Skip malformed lines
      }
    }
    return games;
  }

  TimeControl _parseLichessSpeed(String? speed) {
    switch (speed) {
      case 'bullet':
        return TimeControl.bullet;
      case 'blitz':
        return TimeControl.blitz;
      case 'rapid':
        return TimeControl.rapid;
      case 'classical':
        return TimeControl.rapid;
      case 'correspondence':
        return TimeControl.daily;
      default:
        return TimeControl.unknown;
    }
  }
}

final lichessApiProvider = Provider<LichessApi>((ref) => LichessApi());
