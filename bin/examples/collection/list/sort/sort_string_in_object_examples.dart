import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  _sortStringInObject();
  _sortStringInObjectDescending();
}

class const _Person({required final String name, required final int age}) {
  @override
  String toString() => 'Person(name: $name, age: $age)';
}

List<_Person> _createPersonList() => <_Person>[
  const _Person(name: 'c', age: 3),
  const _Person(name: 'a', age: 1),
  const _Person(name: 'b', age: 2),
];

void _sortStringInObject() {
  final list = _createPersonList()..sortBy((person) => person.name);
  stdout.writeln(list.toString());
}

void _sortStringInObjectDescending() {
  final list = _createPersonList()..sort((a, b) => b.name.compareTo(a.name));
  stdout.writeln(list.toString());
}
