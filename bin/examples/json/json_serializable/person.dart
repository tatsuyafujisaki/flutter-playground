import 'dart:developer' as developer;

import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

// Specify "filedname: FieldRename.snake" as follows if you need to input
// and output JSON whose keys are snake_case.
// @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@JsonSerializable(explicitToJson: true)
class _Person({
  required final String? firstName,
  required final String lastName,
}) {
  factory fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

void _print(_Person person) {
  developer.log(person.firstName.toString());
  developer.log(person.lastName);
  developer.log(person.toJson().toString());
}

void main() {
  final map = <String, dynamic>{'lastName': 'Smith'};
  _print(_Person.fromJson(map));
}
