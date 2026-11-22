import 'dart:io';

enum _Fruit { apple, orange }

void main() {
  stdout
    ..writeln(_Fruit.values.elementAtOrNull(0).toString()) // Apple
    ..writeln(_Fruit.values.elementAtOrNull(1).toString()) // Orange
    ..writeln(_Fruit.values.elementAtOrNull(2).toString()); // null
  // stdout.writeln(_Fruit.values.elementAtOrNull(null).toString()); // Compilation error
}
