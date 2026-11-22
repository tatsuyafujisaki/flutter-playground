import 'dart:developer' as developer;

class _Person1(final String name, final int age) {
  factory fromJson(Map<String, dynamic> map) =>
      _Person1(map['name'] as String, map['age'] as int);
}

class _Person2(Map<String, dynamic> map) {
  final String name = map['name'] as String;
  final int age = map['age'] as int;
}

void main() {
  final map = <String, dynamic>{'name': 'Jane', 'age': 18};
  final person1 = _Person1.fromJson(map);
  developer.log(person1.name);
  final person2 = _Person2(map);
  developer.log(person2.name);
}
