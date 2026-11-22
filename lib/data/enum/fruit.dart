import 'package:collection/collection.dart';

/// A fruit represented by an emoji.
enum Fruit(
  /// The emoji representing this fruit.
  final String emoji,
) {
  /// An unknown fruit.
  unknown(''),

  /// An apple.
  apple('🍎'),

  /// An orange.
  orange('🍊');

  /// Returns the [Fruit] matching [emoji], or [unknown] if none matches.
  factory of(String emoji) =>
      values.firstWhereOrNull((value) => value.emoji == emoji) ?? unknown;
}
