// lib/models/stats_model.dart
class StatsModel {
  final int played;
  final int wins;
  final int winRate;
  final int currentStreak;
  final int maxStreak;
  final List<int> distribution; // index 0 = 1-guess wins, ... index 5 = 6-guess wins

  const StatsModel({
    required this.played,
    required this.wins,
    required this.winRate,
    required this.currentStreak,
    required this.maxStreak,
    required this.distribution,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
        played: (json['played'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        winRate: (json['winRate'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        maxStreak: (json['maxStreak'] as num?)?.toInt() ?? 0,
        distribution: (json['distribution'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [0, 0, 0, 0, 0, 0],
      );

  /// An empty stats object shown before any games are played.
  static const empty = StatsModel(
    played: 0,
    wins: 0,
    winRate: 0,
    currentStreak: 0,
    maxStreak: 0,
    distribution: [0, 0, 0, 0, 0, 0],
  );
}
