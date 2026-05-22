import '../../engine/move_classifier.dart';

/// Time control categories.
enum TimeControl { bullet, blitz, rapid, daily, unknown }

/// A single chess game from Chess.com.
class GameModel {
  const GameModel({
    required this.id,
    required this.url,
    required this.pgn,
    required this.timeControl,
    required this.endTime,
    required this.whiteUsername,
    required this.blackUsername,
    required this.whiteRating,
    required this.blackRating,
    required this.result,
    this.openingName,
    this.openingEco,
    this.whiteAccuracy,
    this.blackAccuracy,
    this.analysisData,
  });

  final String id;
  final String url;
  final String pgn;
  final TimeControl timeControl;
  final int endTime;
  final String whiteUsername;
  final String blackUsername;
  final int whiteRating;
  final int blackRating;
  final String result; // '1-0', '0-1', '1/2-1/2'
  final String? openingName;
  final String? openingEco;
  final double? whiteAccuracy;
  final double? blackAccuracy;
  final GameAnalysisData? analysisData;

  factory GameModel.fromJson(Map<String, dynamic> json) {
    final white = json['white'] as Map<String, dynamic>? ?? {};
    final black = json['black'] as Map<String, dynamic>? ?? {};

    return GameModel(
      id: json['uuid'] as String? ?? json['url'] as String? ?? '',
      url: json['url'] as String? ?? '',
      pgn: json['pgn'] as String? ?? '',
      timeControl: _parseTimeControl(json['time_class'] as String?),
      endTime: json['end_time'] as int? ?? 0,
      whiteUsername: white['username'] as String? ?? '',
      blackUsername: black['username'] as String? ?? '',
      whiteRating: white['rating'] as int? ?? 0,
      blackRating: black['rating'] as int? ?? 0,
      result: white['result'] == 'win'
          ? '1-0'
          : black['result'] == 'win'
              ? '0-1'
              : '1/2-1/2',
      whiteAccuracy: (json['accuracies'] as Map<String, dynamic>?)?['white']
          as double?,
      blackAccuracy: (json['accuracies'] as Map<String, dynamic>?)?['black']
          as double?,
    );
  }

  static TimeControl _parseTimeControl(String? tc) {
    switch (tc) {
      case 'bullet':
        return TimeControl.bullet;
      case 'blitz':
        return TimeControl.blitz;
      case 'rapid':
        return TimeControl.rapid;
      case 'daily':
        return TimeControl.daily;
      default:
        return TimeControl.unknown;
    }
  }

  String get timeControlLabel => switch (timeControl) {
        TimeControl.bullet => 'Bullet',
        TimeControl.blitz => 'Blitz',
        TimeControl.rapid => 'Rapid',
        TimeControl.daily => 'Daily',
        TimeControl.unknown => 'Unknown',
      };

  DateTime get endDateTime =>
      DateTime.fromMillisecondsSinceEpoch(endTime * 1000);

  String resultFor(String username) {
    final isWhite = whiteUsername.toLowerCase() == username.toLowerCase();
    if (result == '1/2-1/2') return '1/2-1/2';
    if (result == '1-0') return isWhite ? '1-0' : '0-1';
    return isWhite ? '0-1' : '1-0';
  }

  double? accuracyFor(String username) {
    final isWhite = whiteUsername.toLowerCase() == username.toLowerCase();
    return isWhite ? whiteAccuracy : blackAccuracy;
  }

  GameModel copyWith({GameAnalysisData? analysisData}) {
    return GameModel(
      id: id,
      url: url,
      pgn: pgn,
      timeControl: timeControl,
      endTime: endTime,
      whiteUsername: whiteUsername,
      blackUsername: blackUsername,
      whiteRating: whiteRating,
      blackRating: blackRating,
      result: result,
      openingName: openingName,
      openingEco: openingEco,
      whiteAccuracy: whiteAccuracy,
      blackAccuracy: blackAccuracy,
      analysisData: analysisData ?? this.analysisData,
    );
  }
}

/// Analysis data for a complete game.
class GameAnalysisData {
  const GameAnalysisData({
    required this.moveClassifications,
    required this.accuracy,
    this.brilliantCount = 0,
    this.blunderCount = 0,
    this.mistakeCount = 0,
    this.inaccuracyCount = 0,
  });

  final List<MoveClassification?> moveClassifications;
  final double accuracy;
  final int brilliantCount;
  final int blunderCount;
  final int mistakeCount;
  final int inaccuracyCount;
}
