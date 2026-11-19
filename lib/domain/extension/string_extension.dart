/// Null-safe emptiness helpers for nullable [String] values.
extension StringExtension on String? {
  /// Whether this string is `null` or empty.
  bool get isNullOrEmpty => this?.isNotEmpty ?? true;

  /// Whether this string is non-null and non-empty.
  bool get isNeitherNullNorEmpty => this?.isNotEmpty ?? false;
}
