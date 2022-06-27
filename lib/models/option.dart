import 'dart:convert';

import 'package:uuid/uuid.dart';

class Option {
  final String id;
  String value;
  bool isChecked;

  Option({
    String? id,
    required this.value,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  Option.empty()
      : id = const Uuid().v4(),
        value = '',
        isChecked = false;

  Option copyWith({
    String? id,
    String? value,
    bool? isChecked,
  }) {
    return Option(
      id: id ?? this.id,
      value: value ?? this.value,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  String toString() => 'Option(id: $id, value: $value, isChecked: $isChecked)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'isChecked': isChecked,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'] ?? '',
      value: map['value'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Option.fromJson(String source) => Option.fromMap(json.decode(source));
}
