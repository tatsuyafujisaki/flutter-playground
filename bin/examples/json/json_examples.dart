import 'dart:convert';
import 'dart:developer' as developer;

import '../freezed/person.dart';

Map<String, dynamic> jsonDecodeToMap(String json) {
  try {
    return jsonDecode(json) as Map<String, dynamic>;
  } on Exception catch (error, stackTrace) {
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
) => toElement(jsonDecode(json) as Map<String, dynamic>);

List<T> _parseArray<T>(
  String json,
  T Function(Map<String, dynamic> json) toElement,
) =>
    List<Map<String, dynamic>>.from(jsonDecode(json) as Iterable<dynamic>)
        .map(toElement)
        .toList();

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
