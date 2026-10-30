// lib/models/game_model.dart
class GameModel {
  final String id;
  final String word;
  final bool won;
  final int attempts;
  final String mode;
  final DateTime date;

  const GameModel({
    required this.id,
    required this.word,
    required this.won,
    required this.attempts,
    required this.mode,
    required this.date,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) => GameModel(
        id: json['_id'] as String? ?? '',
        word: json['word'] as String? ?? '?????',
        won: json['won'] as bool? ?? false,
        attempts: (json['attempts'] as num?)?.toInt() ?? 6,
        mode: json['mode'] as String? ?? 'practice',
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
      );
}
