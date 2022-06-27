import 'dart:convert';

import 'package:flutter/foundation.dart';

class Answers {
  final Map<String, dynamic>? answers;
  Answers({
    required this.answers,
  });

  Answers copyWith({
    Map<String, dynamic>? answers,
  }) {
    return Answers(
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'answers': answers,
    };
  }

  factory Answers.fromMap(Map<String, dynamic> map) {
    map.forEach(
      (key, value) {
        print(key);
        print(value);
      },
    );
    final test = Map<String, dynamic>.from(map);
    print('findmenow');
    print(test);
    return Answers(
      answers: Map<String, dynamic>.from(map['answers']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Answers.fromJson(String source) =>
      Answers.fromMap(json.decode(source));

  @override
  String toString() => 'Answers(answers: $answers)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Answers && mapEquals(other.answers, answers);
  }

  @override
  int get hashCode => answers.hashCode;
}
