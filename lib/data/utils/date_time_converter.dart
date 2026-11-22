import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// A JSON converter for [DateTime] values formatted as `yyyy-MM-dd HH:mm:ss`.
class const DateTimeConverter() implements JsonConverter<DateTime?, String> {
  /// Creates a [DateTimeConverter].
  this;

  static final _format = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Parses [json] into a [DateTime], or returns `null` if parsing fails.
  @override
  DateTime? fromJson(String json) => _format.tryParse(json);

  /// Formats [dateTime] as a string, or returns an empty string if `null`.
  @override
  String toJson(DateTime? dateTime) =>
      dateTime == null ? '' : _format.format(dateTime);
}
