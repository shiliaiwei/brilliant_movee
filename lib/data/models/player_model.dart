/// Chess.com player profile model.
class PlayerModel {
  const PlayerModel({
    required this.username,
    this.name,
    this.avatar,
    this.country,
    this.joined,
    this.lastOnline,
    this.followers = 0,
    this.isStreamer = false,
    this.ratings = const {},
    this.stats,
  });

  final String username;
  final String? name;
  final String? avatar;
  final String? country;
  final int? joined;
  final int? lastOnline;
  final int followers;
  final bool isStreamer;
  final Map<String, int> ratings; // category -> rating
  final PlayerStats? stats;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      username: json['username'] as String? ?? '',
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      country: (json['country'] as String?)?.split('/').last,
      joined: json['joined'] as int?,
      lastOnline: json['last_online'] as int?,
      followers: json['followers'] as int? ?? 0,
      isStreamer: json['is_streamer'] as bool? ?? false,
    );
  }

  PlayerModel copyWith({
    Map<String, int>? ratings,
    PlayerStats? stats,
  }) {
    return PlayerModel(
      username: username,
      name: name,
      avatar: avatar,
      country: country,
      joined: joined,
      lastOnline: lastOnline,
      followers: followers,
      isStreamer: isStreamer,
      ratings: ratings ?? this.ratings,
      stats: stats ?? this.stats,
    );
  }

  String get displayName => name ?? username;

  String get joinedYear {
    if (joined == null) return '';
    return DateTime.fromMillisecondsSinceEpoch(joined! * 1000).year.toString();
  }
}

class PlayerStats {
  const PlayerStats({
    this.rapidRating,
    this.blitzRating,
    this.bulletRating,
    this.dailyRating,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  final int? rapidRating;
  final int? blitzRating;
  final int? bulletRating;
  final int? dailyRating;
  final int wins;
  final int losses;
  final int draws;

  int get totalGames => wins + losses + draws;

  double get winRate =>
      totalGames > 0 ? wins / totalGames : 0;

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    int? extractRating(String key) {
      final cat = json[key] as Map<String, dynamic>?;
      final last = cat?['last'] as Map<String, dynamic>?;
      return last?['rating'] as int?;
    }

    int extractWins(String key) {
      final cat = json[key] as Map<String, dynamic>?;
      final record = cat?['record'] as Map<String, dynamic>?;
      return record?['win'] as int? ?? 0;
    }

    int extractLosses(String key) {
      final cat = json[key] as Map<String, dynamic>?;
      final record = cat?['record'] as Map<String, dynamic>?;
      return record?['loss'] as int? ?? 0;
    }

    int extractDraws(String key) {
      final cat = json[key] as Map<String, dynamic>?;
      final record = cat?['record'] as Map<String, dynamic>?;
      return record?['draw'] as int? ?? 0;
    }

    // Aggregate across all time controls
    final keys = ['chess_rapid', 'chess_blitz', 'chess_bullet', 'chess_daily'];
    int totalWins = 0, totalLosses = 0, totalDraws = 0;
    for (final k in keys) {
      totalWins += extractWins(k);
      totalLosses += extractLosses(k);
      totalDraws += extractDraws(k);
    }

    return PlayerStats(
      rapidRating: extractRating('chess_rapid'),
      blitzRating: extractRating('chess_blitz'),
      bulletRating: extractRating('chess_bullet'),
      dailyRating: extractRating('chess_daily'),
      wins: totalWins,
      losses: totalLosses,
      draws: totalDraws,
    );
  }
}
