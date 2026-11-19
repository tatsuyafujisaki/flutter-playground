import 'dart:developer' as developer;

class _Person1 {
  new(this.name, this.age);
  factory fromJson(Map<String, dynamic> map) =>
      _Person1(map['name'] as String, map['age'] as int);
  final String name;
  final int age;
}

class _Person2 {
  new(Map<String, dynamic> map)
    : name = map['name'] as String,
      age = map['age'] as int;
  final String name;
  final int age;
}

void main() {
  final map = <String, dynamic>{'name': 'Jane', 'age': 18};
  final person1 = _Person1.fromJson(map);
  developer.log(person1.name);
  final person2 = _Person2(map);
  developer.log(person2.name);
}
