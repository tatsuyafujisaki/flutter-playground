import 'dart:convert';
import 'dart:developer' as developer;

import '../freezed/person.dart';

Map<String, dynamic> jsonDecodeToMap(String json) {
  try {
    if (jsonDecode(json) case final Map<String, dynamic> map) {
      return map;
    }
    developer.log('Decoded JSON is not an object: $json');
  } on FormatException catch (error, stackTrace) {
    developer.log(
      'Failed to decode JSON to map',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return <String, dynamic>{};
}

String minifyJson(String json) => jsonEncode(jsonDecode(json));

T _parseObject<T>(
  String json,
  T Function(Map<String, dynamic> json) toElement,
) => switch (jsonDecode(json)) {
  final Map<String, dynamic> map => toElement(map),
  final decoded => throw FormatException('Expected JSON object: $decoded'),
};

List<T> _parseArray<T>(
  String json,
  T Function(Map<String, dynamic> json) toElement,
) => switch (jsonDecode(json)) {
  final List<dynamic> list => [
    for (final item in list)
      switch (item) {
        final Map<String, dynamic> map => toElement(map),
        _ => throw FormatException('Expected JSON object element: $item'),
      },
  ],
  final decoded => throw FormatException('Expected JSON array: $decoded'),
};

void _logJsonRootType(String json) {
  developer.log(jsonDecode(json).runtimeType.toString());
}

void main() {
  developer.log(jsonDecodeToMap('{"a": 1}').toString());
  developer.log(minifyJson('{"a": 1, "b": 2}'));

  developer.log(
    _parseObject('{ "name": "John", "age": 42 }', Person.fromJson).toString(),
  );
  developer.log(
    _parseArray(
      '[{ "name": "John", "age": 42 }, { "name": "Jane", "age": 18 }]',
      Person.fromJson,
    ).toString(),
  );

  _logJsonRootType('{ "name": "Jane", "age": 18 }'); // _Map<String, dynamic>

  _logJsonRootType('["a", "b"]'); // List<dynamic>

  _logJsonRootType('-1'); // int
  _logJsonRootType('3.14'); // double

  _logJsonRootType('"abc"'); // String

  _logJsonRootType('true'); // bool
  _logJsonRootType('false'); // bool

  _logJsonRootType('null'); // Null
}
