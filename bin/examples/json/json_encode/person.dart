import 'dart:convert';
import 'dart:developer' as developer;

class _Person {
  _Person(this.name, this.age);

  factory _Person.fromJson(Map<String, dynamic> json) => switch (json) {
    {'name': final String name, 'age': final int age} => _Person(name, age),
    _ => throw FormatException('Invalid person JSON: $json'),
  };

  final String name;
  final int age;

  // jsonEncode() implicitly calls toJson().
  Map<String, dynamic> toJson() => {'name': name, 'age': 10};
}

void main() {
  const json = '{"name": "Nobita", "age": 10}';
  final map = jsonDecode(json) as Map<String, dynamic>;
  final user = _Person.fromJson(map);
  final encoded = jsonEncode(user);
  developer.log(encoded);
}
