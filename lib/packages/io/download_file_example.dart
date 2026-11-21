import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Downloads binary data from [url] and returns the response bytes.
Future<Uint8List> downloadBinaryFile(String url, {Dio? dio}) async {
  final client = dio ?? Dio();
  try {
    final response = await client.get<List<int>>(
      url,
      options: Options(responseType: .bytes),
    );
    final data = response.data;
    if (data != null) {
      return Uint8List.fromList(data);
    }
    throw Exception(
      '''Status code: ${response.statusCode}\nStatus message: ${response.statusMessage}\nURL: $url''',
    );
  } finally {
    if (dio == null) {
      client.close();
    }
  }
}

/// Downloads text content from [uri] and returns the response body.
Future<String> downloadTextFile(Uri uri, {Dio? dio}) async {
  final client = dio ?? Dio();
  try {
    final response = await client.getUri<String>(
      uri,
      options: Options(responseType: .plain),
    );
    final data = response.data;
    if (data != null) {
      return data;
    }
    throw Exception(
      '''Status code: ${response.statusCode}\nStatus message: ${response.statusMessage}\nURL: $uri''',
    );
  } finally {
    if (dio == null) {
      client.close();
    }
  }
}
