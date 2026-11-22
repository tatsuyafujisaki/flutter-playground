import 'dart:io';

import 'package:flutter_playground/data/enum/fruit.dart';

void main() {
  stdout
    ..writeln(Fruit.values.elementAtOrNull(0)) // Fruit.unknown
    ..writeln(Fruit.values.elementAtOrNull(1)) // Fruit.apple
    ..writeln(Fruit.values.elementAtOrNull(2)) // Fruit.orange
    ..writeln(Fruit.values.elementAtOrNull(3)); // null
  // stdout.writeln(Fruit.values.elementAtOrNull(null)); // Compilation error

  switch (Fruit.of('🍎')) {
    case .unknown:
      stdout.writeln('Unknown fruit!');
    case .apple:
      stdout.writeln('Apple!');
    case .orange:
      stdout.writeln('Orange!');
  }
}
