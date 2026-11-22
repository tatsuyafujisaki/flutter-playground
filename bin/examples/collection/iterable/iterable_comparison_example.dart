import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final iterable1 = <String>['🍎', '🍊'] as Iterable<String>;
  final iterable2 = <String>['🍎', '🍊'] as Iterable<String>;
  final iterable3 = <String>['🍊', '🍎'] as Iterable<String>;

  const iterableEquality = IterableEquality<String>();

  stdout
    ..writeln(iterable1 == iterable2) // false
    ..writeln(iterableEquality.equals(iterable1, iterable2)) // true
    ..writeln(iterableEquality.equals(iterable1, iterable3)); // false
}
