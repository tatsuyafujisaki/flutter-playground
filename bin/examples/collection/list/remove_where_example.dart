import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'remove_where_example.freezed.dart';

/// A fruit represented by an emoji.
@freezed
sealed class Fruit with _$Fruit {
  /// Creates a [Fruit].
  const factory({required String emoji}) = _Fruit;
}

void main() {
  final fruits = [
    const Fruit(emoji: '🍎'),
    const Fruit(emoji: '🍏'),
    const Fruit(emoji: '🍊'),
  ];

  stdout.writeln(fruits.toString());
  fruits.removeWhere((fruits) => fruits.emoji == '🍏');
  stdout.writeln(fruits.toString());
}
