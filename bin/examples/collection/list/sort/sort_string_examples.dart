import 'dart:io';

void main() {
  _sortString();
  _sortStringDescending();
}

void _sortString() {
  final list = <String>['c', 'b', 'a']..sort();
  stdout.writeln(list.toString()); // [a, b, c]
}

void _sortStringDescending() {
  final list = <String>['c', 'b', 'a']..sort((a, b) => b.compareTo(a));
  stdout.writeln(list.toString()); // [c, b, a]
}
