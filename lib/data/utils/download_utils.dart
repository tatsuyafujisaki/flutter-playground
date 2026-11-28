import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Downloads binary data from [url] with [dio] and returns the response bytes.
Future<Uint8List> downloadBinaryFile(Dio dio, String url) async {
  final bytes = await _download<List<int>>(
    url: url,
    send: () => dio.get<List<int>>(url, options: Options(responseType: .bytes)),
  );
  return Uint8List.fromList(bytes);
}

/// Downloads text content from [uri] with [dio] and returns the response body.
Future<String> downloadTextFile(Dio dio, Uri uri) => _download<String>(
  url: uri.toString(),
  send: () => dio.getUri<String>(uri, options: Options(responseType: .plain)),
);

Future<T> _download<T>({
  required String url,
  required Future<Response<T>> Function() send,
}) async {
  final response = await send();
  if (response.data case final data?) {
    return data;
  }
  throw Exception(
    'Status code: ${response.statusCode}\n'
    'Status message: ${response.statusMessage}\n'
    'URL: $url',
  );
}
