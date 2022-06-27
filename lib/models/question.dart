import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:stream_quiz_app/models/option.dart';

class QuestionMessage {
  int question;
  String gameID;
  QuestionMessage({
    required this.question,
    required this.gameID,
  });

  QuestionMessage copyWith({
    int? question,
    String? gameID,
  }) {
    return QuestionMessage(
      question: question ?? this.question,
      gameID: gameID ?? this.gameID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'gameID': gameID,
    };
  }

  factory QuestionMessage.fromMap(Map<String, dynamic> map) {
    return QuestionMessage(
      question: map['question']?.toInt() ?? 0,
      gameID: map['gameID'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory QuestionMessage.fromJson(String source) =>
      QuestionMessage.fromMap(json.decode(source));

  @override
  String toString() => 'QuestionMessage(question: $question, gameID: $gameID)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionMessage &&
        other.question == question &&
        other.gameID == gameID;
  }

  @override
  int get hashCode => question.hashCode ^ gameID.hashCode;
}

class Question {
  String id;
  String question;
  List<Option> options;

  Question({
    String? id,
    required this.question,
    required this.options,
  }) : id = id ?? const Uuid().v4();

  Question.empty()
      : id = const Uuid().v4(),
        question = '',
        options = [Option.empty()];

  Question copyWith({
    String? id,
    String? question,
    List<Option>? options,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }

  @override
  String toString() =>
      'Question(id: $id, question: $question, options: $options)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<Option>.from(map['options']?.map((x) => Option.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Question.fromJson(String source) =>
      Question.fromMap(json.decode(source));
}
