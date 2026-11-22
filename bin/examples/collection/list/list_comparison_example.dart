import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final list1 = <String>['🍎', '🍊'];
  final list2 = <String>['🍎', '🍊'];
  final list3 = <String>['🍊', '🍎'];

  const listEquality = ListEquality<String>();

  stdout
    ..writeln((list1 == list2).toString()) // false
    ..writeln(listEquality.equals(list1, list2).toString()) // true
    ..writeln(listEquality.equals(list1, list3).toString()); // false
}
