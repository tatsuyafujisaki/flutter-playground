import 'package:dio/dio.dart';
import 'package:flutter_playground/ui/example/io/download_file_example.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDio({
  final Future<Response<dynamic>> Function(String path, Options? options)?
  onGet,
  final Future<Response<dynamic>> Function(Uri uri, Options? options)? onGetUri,
}) extends Fake implements Dio {
  bool isClosed = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onGet!(path, options);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
  }

  @override
  Future<Response<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onGetUri!(uri, options);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
  }

  @override
  void close({bool force = false}) {
    isClosed = true;
  }
}

void main() {
  group('download_file_example', () {
    test('downloadBinaryFile returns bytes with ResponseType.bytes', () async {
      final dio = _FakeDio(
        onGet: (path, options) async {
          expect(path, 'https://example.com/file.bin');
          expect(options?.responseType, ResponseType.bytes);
          return Response<List<int>>(
            requestOptions: RequestOptions(path: path),
            data: const [1, 2, 3, 4],
            statusCode: 200,
          );
        },
      );

      final bytes = await downloadBinaryFile(
        'https://example.com/file.bin',
        dio: dio,
      );
      expect(bytes, [1, 2, 3, 4]);
      expect(dio.isClosed, isFalse);
    });

    test('downloadTextFile returns string with ResponseType.plain', () async {
      final uri = Uri.parse('https://example.com/robots.txt');
      final dio = _FakeDio(
        onGetUri: (requestedUri, options) async {
          expect(requestedUri, uri);
          expect(options?.responseType, ResponseType.plain);
          return Response<String>(
            requestOptions: RequestOptions(path: requestedUri.toString()),
            data: 'User-agent: *',
            statusCode: 200,
          );
        },
      );

      final text = await downloadTextFile(uri, dio: dio);
      expect(text, 'User-agent: *');
      expect(dio.isClosed, isFalse);
    });

    test('throws Exception when response data is null', () async {
      final dio = _FakeDio(
        onGet: (path, _) async => Response<List<int>>(
          requestOptions: RequestOptions(path: path),
          statusCode: 204,
          statusMessage: 'No Content',
        ),
      );

      await expectLater(
        downloadBinaryFile('https://example.com/empty', dio: dio),
        throwsException,
      );
    });
  });
}
