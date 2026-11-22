# How to print the Dart version

```dart
import 'dart:io';

void main() {
  stdout.writeln(Platform.version); // x.x.x (stable)
}
```

https://api.flutter.dev/flutter/dart-io/Platform/version.html

# Required, optional, named, and positional parameters

## Example of positional (unnamed) parameters

```dart
import 'dart:io';

// `a` is a required positional parameter.
// `b` is an optional positional parameter whose default value is `null`.
// `c` is an optional positional parameter with a default value.
class MyClass(
  final String a, [
  final String? b,
  final String c = 'default!',
]) {
  this {
    stdout.writeln('a = $a, b = $b, c = $c');
  }
}

void myFunction(
  String a, [
  String? b,
  String c = 'default!',
]) {
  stdout.writeln('a = $a, b = $b, c = $c');
}

void main() {
  MyClass('a');
  MyClass('a', 'b');
  MyClass('a', 'b', 'c');

  myFunction('a');
  myFunction('a', 'b');
  myFunction('a', 'b', 'c');
}
```

## Example of named parameters

```dart
import 'dart:io';

// `a` is a required positional parameter.
// `b` is a required named parameter.
// `c` is an optional named parameter whose default value is `null`.
// `d` is an optional named parameter with a default value.
class MyClass(
  final String a, {
  required final String b,
  final String? c,
  final String d = 'default!',
}) {
  this {
    stdout.writeln('a = $a, b = $b, c = $c, d = $d');
  }
}

void myFunction(
  String a, {
  required String b,
  String? c,
  String d = 'default!',
}) {
  stdout.writeln('a = $a, b = $b, c = $c, d = $d');
}

void main() {
  MyClass('a', b: 'b');
  MyClass('a', b: 'b', c: 'c');
  MyClass('a', b: 'b', c: 'c', d: 'd');

  myFunction('a', b: 'b');
  myFunction('a', b: 'b', c: 'c');
  myFunction('a', b: 'b', c: 'c', d: 'd');
}
```

# List

## How to copy a `List`

```dart
import 'dart:io';

void main() {
  final list1 = <String>['🍎', '🍊'];
  final list2 = List.of(list1);
  list2[0] = '🍏';
  stdout.writeln(list1); // [🍎, 🍊]
  stdout.writeln(list2); // [🍏, 🍊]
}
```

## How to convert `List<dynamic>` to `List<String>`

```dart
import 'dart:io';

void main() {
  final list1 = <dynamic>['🍎'];
  stdout.writeln(list1.runtimeType); // List<dynamic>

  final list2 = List<String>.from(list1);
  stdout.writeln(list2.runtimeType); // List<String>

  // Not recommended:
  // > DON'T use cast() when a nearby operation will do
  // https://dart.dev/effective-dart/usage#dont-use-cast-when-a-nearby-operation-will-do
  // > AVOID using cast()
  // https://dart.dev/effective-dart/usage#avoid-using-cast
  final list3 = list1.cast<String>().toList();
  stdout.writeln(list3.runtimeType); // List<String>
}
```

## How to get an item

```dart
import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final fruits = ['🍎'];
  stdout.writeln(fruits.elementAtOrNull(0)); // 🍎
  stdout.writeln(fruits.elementAtOrNull(1)); // null
  stdout.writeln(fruits.firstWhereOrNull((element) => element == '🍏')); // null
  stdout.writeln(
    fruits.firstWhere((element) => element == '🍏', orElse: () => 'Not found!'),
  ); // Not found!
}
```

## Difference between `List` and `UnmodifiableListView`

| Operation                 | `List` | `UnmodifiableListView` |
| ------------------------- | ------ | ---------------------- |
| Can add or remove an item | Yes    | No                     |
| Can replace an item       | Yes    | No                     |

### Example of modifying a `List`

```dart
import 'dart:io';

void main() {
  final fruits = ['🍎']
    ..remove('🍎')
    ..add('🍏');

  fruits[0] = '🍊';
  stdout.writeln(fruits); // [🍊]
}
```

### Example of `UnmodifiableListView`

```dart
import 'dart:collection';

void main() {
  final fruits = UnmodifiableListView(['🍎']);

  // Throws "Unsupported operation: Cannot add to an unmodifiable list".
  // fruits.add('🍏');

  // Throws "Unsupported operation: Cannot remove from an unmodifiable list".
  // fruits.remove('🍎');

  // Throws "Unsupported operation: Cannot modify an unmodifiable list".
  // fruits[0] = '🍏';
}
```

# Set

## How to copy a `Set`

```dart
import 'dart:io';

void main() {
  final set1 = <String>{'🍎', '🍊'};
  final set2 = Set.of(set1)
    ..remove('🍎')
    ..add('🍏');
  stdout.writeln(set1); // {🍎, 🍊}
  stdout.writeln(set2); // {🍊, 🍏}
}
```

# Map

## How to get an item from a `Map`

```dart
import 'dart:io';

void main() {
  final map = <String, String>{'apple': '🍎'};
  stdout.writeln(map['apple']); // 🍎
  stdout.writeln(map['orange']); // null
}
```

## How to copy a `Map`

```dart
import 'dart:io';

void main() {
  final map1 = <String, String>{'apple': '🍎', 'orange': '🍊'};
  final map2 = Map.of(map1);
  map2['apple'] = '🍏';
  stdout.writeln(map1); // {apple: 🍎, orange: 🍊}
  stdout.writeln(map2); // {apple: 🍏, orange: 🍊}
}
```

# What in Dart is equivalent to scope functions in Kotlin?

Cascade notation (`..`, `?..`)

https://dart.dev/language/operators#cascade-notation
