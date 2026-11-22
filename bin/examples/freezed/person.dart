import 'dart:convert';
import 'dart:io';

import 'package:flutter_playground/data/utils/date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

/// A person with a name, age, and optional last-updated timestamp.
@freezed
sealed class Person with _$Person {
  /// Creates a [Person].
  const factory({
    required String name,
    required int age,
    @DateTimeConverter() DateTime? lastUpdated,
  }) = _Person;

  /// Creates a [Person] from a JSON map.
  factory fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

void main() {
  final person = const Person(
    name: 'John',
    age: 42,
  ).copyWith(lastUpdated: .now());
  final map = person.toJson();
  stdout.writeln(map.toString());
  final personFromJson = Person.fromJson(map);
  stdout
    ..writeln(personFromJson.toString())
    ..writeln(jsonEncode(person)); // jsonEncode implicitly calls toJson.
}
