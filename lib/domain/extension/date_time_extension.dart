/// Convenience comparison and date helpers for [DateTime].
extension DateTimeExtension on DateTime {
  /// Returns whether this [DateTime] is before or equal to [other].
  bool isBeforeOrEqualTo(DateTime other) => !isAfter(other);

  /// Returns whether this [DateTime] is after or equal to [other].
  bool isAfterOrEqualTo(DateTime other) => !isBefore(other);

  /// A [DateTime] with the same year, month, and day at midnight.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether this [DateTime] falls on the current calendar day.
  bool get isToday => dateOnly == DateTime.now().dateOnly;
}
