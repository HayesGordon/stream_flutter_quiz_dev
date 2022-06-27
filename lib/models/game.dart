import 'dart:convert';

import 'player.dart';
import 'quiz.dart';

class Game {
  final String id;
  final Player host;
  final int activeQuestion;
  final Quiz quiz;
  final bool completed;
  final bool started;

  Game({
    required this.id,
    required this.host,
    required this.activeQuestion,
    required this.quiz,
    required this.completed,
    required this.started,
  });

  Game copyWith({
    String? id,
    Player? host,
    int? activeQuestion,
    Quiz? quiz,
    bool? completed,
    bool? started,
  }) {
    return Game(
      id: id ?? this.id,
      host: host ?? this.host,
      activeQuestion: activeQuestion ?? this.activeQuestion,
      quiz: quiz ?? this.quiz,
      completed: completed ?? this.completed,
      started: started ?? this.started,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host.toMap(),
      'activeQuestion': activeQuestion,
      'quiz': quiz.toMap(),
      'completed': completed,
      'started': started,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? '',
      host: Player.fromMap(map['host']),
      activeQuestion: map['activeQuestion']?.toInt() ?? 0,
      quiz: Quiz.fromMap(map['quiz']),
      completed: map['completed'] ?? false,
      started: map['started'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) => Game.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Game(id: $id, host: $host, activeQuestion: $activeQuestion, quiz: $quiz, completed: $completed, started: $started)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Game &&
        other.id == id &&
        other.host == host &&
        other.activeQuestion == activeQuestion &&
        other.quiz == quiz &&
        other.completed == completed &&
        other.started == started;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        host.hashCode ^
        activeQuestion.hashCode ^
        quiz.hashCode ^
        completed.hashCode ^
        started.hashCode;
  }
}
