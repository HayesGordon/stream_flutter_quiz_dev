import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:stream_quiz_app/models/models.dart';

class QuizResult {
  final Game game;
  final Map<String, num> scores;
  QuizResult({
    required this.game,
    required this.scores,
  });

  QuizResult copyWith({
    Game? game,
    Map<String, num>? scores,
  }) {
    return QuizResult(
      game: game ?? this.game,
      scores: scores ?? this.scores,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game': game.toMap(),
      'scores': scores,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      game: Game.fromMap(map['game']),
      scores: Map<String, num>.from(map['scores']),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizResult.fromJson(String source) =>
      QuizResult.fromMap(json.decode(source));

  @override
  String toString() => 'QuizResult(game: $game, scores: $scores)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizResult &&
        other.game == game &&
        mapEquals(other.scores, scores);
  }

  @override
  int get hashCode => game.hashCode ^ scores.hashCode;
}
