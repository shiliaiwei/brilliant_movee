class LeaderboardPlayer {
  const LeaderboardPlayer({
    required this.username,
    required this.rank,
    required this.score,
    this.avatar,
    this.name,
    this.country,
  });

  final String username;
  final int rank;
  final int score;
  final String? avatar;
  final String? name;
  final String? country;

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayer(
      username: json['username'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      avatar: json['avatar'] as String?,
      name: json['name'] as String?,
      country: (json['country'] as String?)?.split('/').last,
    );
  }

  String get displayName => name ?? username;
}
