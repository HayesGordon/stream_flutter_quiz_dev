import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Player {
  final String uid;
  final String? name;
  final String? photoUrl;
  final Map<String, dynamic>? answers;

  Player({
    required this.uid,
    this.name,
    this.photoUrl,
    this.answers,
  });

  factory Player.fromFirebaseUser(User user) {
    return Player(
      uid: user.uid,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Player copyWith({
    String? uid,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? answers,
  }) {
    return Player(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'answers': answers,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    final tmpAnswers = map['answers'];
    return Player(
      uid: map['uid'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      answers: tmpAnswers,
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Player(uid: $uid, name: $name, photoUrl: $photoUrl, answers: $answers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Player &&
        other.uid == uid &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        mapEquals(other.answers, answers);
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ photoUrl.hashCode ^ answers.hashCode;
  }
}
