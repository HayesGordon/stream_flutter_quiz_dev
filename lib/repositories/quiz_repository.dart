import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_quiz_app/models/models.dart';
import 'package:stream_quiz_app/models/quiz_result.dart';

class QuizRepository {
  QuizRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // late final _quizesCollection = _firestore.collection('quizes').withConverter(
  //       fromFirestore: (snapshot, options) => Quiz.fromMap(snapshot.data()!),
  //       toFirestore: (Quiz quiz, options) => quiz.toMap(),
  //     );
  // late final _userCollection = _firestore.collection('users');

  // CollectionReference<Map<String, dynamic>> questionsCollection(
  //         String quizId) =>
  //     _quizesCollection.doc(quizId).collection('questions');

  Future<void> createOrUpdateQuiz(Quiz quiz) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('quizes')
        .doc(quiz.id)
        .set(quiz.toMap());
  }

  Future<void> deleteQuiz(Quiz quiz) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('quizes')
        .doc(quiz.id)
        .delete();
  }

  Future<Quiz> getQuiz(String quizId) async {
    final doc = await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('quizes')
        .doc(quizId)
        .get();
    if (doc.data() == null) throw Exception('Quiz does not exist');
    return Quiz.fromMap(doc.data()!);
  }

  Future<List<Quiz>> getUserQuizes() async {
    return _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('quizes')
        .get()
        .then((value) {
      return value.docs.map((e) => Quiz.fromMap(e.data())).toList();
    });
  }

  Stream<List<Quiz>> yourQuizesStream() {
    final docRef = _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('quizes');

    return docRef.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (e) => Quiz.fromMap(e.data()),
              )
              .toList(),
        );
  }

  Future<String> createNewGame(String quizId) async {
    final docRef = await _firestore.collection('games').add({'quizId': quizId});

    return docRef.id;
  }

  Future<String> createGame(Player host, String quizId) async {
    final quiz = await getQuiz(quizId);
    final doc = _firestore.collection('games').doc();
    final game = Game(
      id: doc.id,
      host: host,
      activeQuestion: 0,
      quiz: quiz,
      completed: false,
      started: false,
    );
    await doc.set(game.toMap());
    return doc.id;
  }

  Future<void> startGame(String gameId) async {
    await _firestore.collection('games').doc(gameId).update({
      'started': true,
    });
  }

  Future<void> endGame(String gameId) async {
    await _firestore.collection('games').doc(gameId).update({
      'completed': true,
    });
  }

  Future<Game?> getGame(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();
    if (doc.data() == null) {
      return null;
    }
    return Game.fromMap(doc.data()!);
  }

  Stream<Game> gameStream(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((snapshot) {
      return Game.fromMap(snapshot.data()!);
    });
  }

  Stream<List<Player>> gamePlayerStream(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('players')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(
        (e) {
          return Player.fromMap(e.data());
        },
      ).toList();
    });
  }

  Future<void> joinGame({required String gameId, required Player user}) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('players')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<void> answerQuestion({
    required String gameId,
    required String userId,
    required int questionNr,
    required Set<String> answers,
  }) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('players')
        .doc(userId)
        .update({
      'answers.$questionNr': {
        'timestamp': FieldValue.serverTimestamp(),
        'answers': answers.toList(),
      }
    });
    //     .update({
    //   'answers': {
    //     '$questionNr': {
    //       'timestamp': FieldValue.serverTimestamp(),
    //       'answers': answers.toList(),
    //     }
    //   }
    // });
  }

  Future<QuizResult> calulateGameResults(String gameId) async {
    final game = await getGame(gameId);
    final questions = game!.quiz.questions;

    final playersCollection = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('players')
        .get();

    final players = playersCollection.docs.map((e) => Player.fromMap(e.data()));

    Map<String, double> playersScore = {};

    for (var player in players) {
      final answers = player.answers;
      double score = 0;
      answers?.forEach((key, value) {
        final currentQuestion = questions[int.parse(key)];

        final correctOptions = List<Option>.from(currentQuestion.options)
          ..retainWhere((element) => element.isChecked);
        final correctOptionsById = correctOptions.map((e) => e.id).toList();

        final numberOfOptions = currentQuestion.options.length;
        final numberOfCorrectOptions = correctOptionsById.length;
        final pointValue = 1 / numberOfCorrectOptions;
        final penaltyValue = 1 / numberOfOptions;

        final playerAnswers = value['answers'] as List;
        final numberOfAnswers = playerAnswers.length;

        for (final playerAnswer in playerAnswers) {
          if (correctOptionsById.contains(playerAnswer)) {
            score += pointValue;
          } else {
            if (numberOfAnswers > numberOfCorrectOptions) {
              score -= penaltyValue;
            }
          }
        }
      });
      playersScore[player.uid] = score;
    }
    return QuizResult(game: game, scores: playersScore);
  }
}

typedef OverlayVisibility = ValueNotifier<bool>;
