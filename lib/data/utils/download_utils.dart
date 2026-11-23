import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Downloads binary data from [url] and returns the response bytes.
Future<Uint8List> downloadBinaryFile(String url, {Dio? dio}) async {
  final bytes = await _download<List<int>>(
    url: url,
    dio: dio,
    send: (client) =>
        client.get<List<int>>(url, options: Options(responseType: .bytes)),
  );
  return Uint8List.fromList(bytes);
}

/// Downloads text content from [uri] and returns the response body.
Future<String> downloadTextFile(Uri uri, {Dio? dio}) => _download<String>(
  url: uri.toString(),
  dio: dio,
  send: (client) =>
      client.getUri<String>(uri, options: Options(responseType: .plain)),
);

Future<T> _download<T>({
  required String url,
  required Future<Response<T>> Function(Dio client) send,
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  try {
    final response = await send(client);
    if (response.data case final data?) {
      return data;
    }
    throw Exception(
      'Status code: ${response.statusCode}\n'
      'Status message: ${response.statusMessage}\n'
      'URL: $url',
    );
  } finally {
    if (dio == null) {
      client.close();
    }
  }
}
