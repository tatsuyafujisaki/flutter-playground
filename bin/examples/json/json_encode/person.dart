import 'dart:convert';
import 'dart:developer' as developer;

class _Person(final String name, final int age) {
  factory fromJson(Map<String, dynamic> json) => switch (json) {
    {'name': final String name, 'age': final int age} => _Person(name, age),
    _ => throw FormatException('Invalid person JSON: $json'),
  };

  // jsonEncode() implicitly calls toJson().
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

void main() {
  const json = '{"name": "Nobita", "age": 10}';
  final map = jsonDecode(json) as Map<String, dynamic>;
  final user = _Person.fromJson(map);
  final encoded = jsonEncode(user);
  developer.log(encoded);
}
