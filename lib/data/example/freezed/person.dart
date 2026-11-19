import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_playground/data/utils/date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

/// A person with a name, age, and optional last-updated timestamp.
@freezed
sealed class Person with _$Person {
  /// Creates a [Person].
  const factory Person({
    required String name,
    required int age,
    @DateTimeConverter() DateTime? lastUpdated,
  }) = _Person;

  /// Creates a [Person] from a JSON map.
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

void main() {
  final person = const Person(
    name: 'John',
    age: 42,
  ).copyWith(lastUpdated: DateTime.now());
  final map = person.toJson();
  developer.log(map.toString());
  final personFromJson = Person.fromJson(map);
  developer.log(personFromJson.toString());
  developer.log(jsonEncode(person)); // jsonEncode implicitly calls toJson.
}
