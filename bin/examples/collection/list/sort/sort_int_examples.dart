import 'dart:io';

void main() {
  _sortInt();
  _sortIntDescending();
}

void _sortInt() {
  final list = <int>[3, 1, 2]..sort();
  stdout.writeln(list.toString()); // [1, 2, 3]
}

void _sortIntDescending() {
  final list = <int>[3, 1, 2]..sort((a, b) => b.compareTo(a));
  stdout.writeln(list.toString()); // [3, 2, 1]
}
