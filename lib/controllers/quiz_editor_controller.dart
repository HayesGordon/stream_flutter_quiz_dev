import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:stream_quiz_app/models/models.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';

class QuizEditorState {
  final String id;
  String name;
  final List<Question> questions;
  bool isPublished;

  QuizEditorState({
    String? id,
    required this.name,
    this.questions = const [],
    this.isPublished = false,
  }) : id = id ?? const Uuid().v4();

  QuizEditorState.initial()
      : name = 'Quiz name',
        isPublished = false,
        questions = [
          Question(question: 'What is your favourite color', options: [
            Option(value: 'Red'),
            Option(value: 'Green'),
            Option(value: 'Blue'),
          ]),
          Question(question: 'What is your favourite animal', options: [
            Option(value: 'Dog'),
            Option(value: 'Cat'),
            Option(value: 'Hamster'),
          ])
        ],
        id = const Uuid().v4();

  QuizEditorState copyWith({
    String? id,
    String? name,
    List<Question>? questions,
    bool? isPublished,
  }) {
    return QuizEditorState(
      id: id ?? this.id,
      name: name ?? this.name,
      questions: questions ?? this.questions,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Quiz toQuiz() {
    return Quiz(
      id: id,
      name: name,
      questions: questions,
    );
  }

  factory QuizEditorState.fromQuiz(Quiz quiz) => QuizEditorState(
        id: quiz.id,
        questions: quiz.questions,
        isPublished: true,
        name: quiz.name,
      );

  @override
  String toString() {
    return 'QuizEditorState(id: $id, name: $name, questions: $questions, isPublished: $isPublished)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'questions': questions.map((x) => x.toMap()).toList(),
      'isPublished': isPublished,
    };
  }

  factory QuizEditorState.fromMap(Map<String, dynamic> map) {
    return QuizEditorState(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      questions: List<Question>.from(
          map['questions']?.map((x) => Question.fromMap(x))),
      isPublished: map['isPublished'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizEditorState.fromJson(String source) =>
      QuizEditorState.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizEditorState &&
        other.id == id &&
        other.name == name &&
        listEquals(other.questions, questions) &&
        other.isPublished == isPublished;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        questions.hashCode ^
        isPublished.hashCode;
  }
}

class QuizEditorController extends ChangeNotifier {
  QuizEditorController({
    required this.repository,
    QuizEditorState? state,
  }) : state = state ?? QuizEditorState.initial();

  QuizEditorState state;
  QuizRepository repository;

  void addNewQuestion() {
    state.questions.add(Question.empty());
    notifyListeners();
  }

  void addNewOption(String questionId) {
    final question =
        state.questions.firstWhere((element) => element.id == questionId);
    question.options.add(Option.empty());

    notifyListeners();
  }

  void removeOption(String questionId, String optionId) {
    final question =
        state.questions.firstWhere((element) => element.id == questionId);

    question.options.removeWhere((element) => element.id == optionId);
    notifyListeners();
  }

  Future<void> saveChanges() async {
    try {
      await repository.createOrUpdateQuiz(state.toQuiz());
      state.isPublished = true;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
