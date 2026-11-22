/// Convenience comparison and date helpers for [DateTime].
extension DateTimeExtension on DateTime {
  /// Returns whether this [DateTime] is before or equal to [other].
  bool isBeforeOrEqualTo(DateTime other) => !isAfter(other);

  /// Returns whether this [DateTime] is after or equal to [other].
  bool isAfterOrEqualTo(DateTime other) => !isBefore(other);

  /// A [DateTime] with the same year, month, and day at midnight, preserving
  /// whether this [DateTime] is in UTC or local time.
  DateTime get dateOnly =>
      isUtc ? .utc(year, month, day) : .new(year, month, day);

  /// Whether this [DateTime] falls on the current local calendar day.
  bool get isToday => toLocal().dateOnly == DateTime.now().dateOnly;
}
