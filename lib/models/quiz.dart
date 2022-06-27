import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:stream_quiz_app/models/question.dart';

class Quiz {
  final String id;
  final String name;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.name,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'questions': questions.map((x) => x.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      questions: List<Question>.from(
          map['questions']?.map((x) => Question.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Quiz.fromJson(String source) => Quiz.fromMap(json.decode(source));

  Quiz copyWith({
    String? id,
    String? name,
    List<Question>? questions,
  }) {
    return Quiz(
      id: id ?? this.id,
      name: name ?? this.name,
      questions: questions ?? this.questions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Quiz &&
        other.id == id &&
        other.name == name &&
        listEquals(other.questions, questions);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ questions.hashCode;

  @override
  String toString() => 'Quiz(id: $id, name: $name, questions: $questions)';
}
