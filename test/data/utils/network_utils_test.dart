import 'package:dio/dio.dart';
import 'package:flutter_playground/data/utils/network_utils.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDio({
  final Future<Response<void>> Function(Uri uri)? onHeadUri,
  final Future<Response<void>> Function(Uri uri)? onGetUri,
}) extends Fake implements Dio {
  bool isClosed = false;

  @override
  Future<Response<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await onHeadUri!(uri);
    return Response<T>(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
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
    final response = await onGetUri!(uri);
    return Response<T>(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
    );
  }

  @override
  void close({bool force = false}) {
    isClosed = true;
  }
}

Response<void> _statusResponse(Uri uri, int statusCode) => Response<void>(
  requestOptions: RequestOptions(path: uri.toString()),
  statusCode: statusCode,
);

void main() {
  group('isUrlAccessible', () {
    test(
      'returns true for 2xx HEAD response without closing passed Dio',
      () async {
        final dio = _FakeDio(
          onHeadUri: (uri) async => _statusResponse(uri, 200),
        );

        expect(await isUrlAccessible('https://example.com', dio: dio), isTrue);
        expect(dio.isClosed, isFalse);
      },
    );

    test('falls back to GET when HEAD returns 405', () async {
      var getCalled = false;
      final dio = _FakeDio(
        onHeadUri: (uri) async => _statusResponse(uri, 405),
        onGetUri: (uri) async {
          getCalled = true;
          return _statusResponse(uri, 204);
        },
      );

      expect(await isUrlAccessible('https://example.com', dio: dio), isTrue);
      expect(getCalled, isTrue);
    });

    test('returns false for non-2xx status codes and exceptions', () async {
      final notFoundDio = _FakeDio(
        onHeadUri: (uri) async => _statusResponse(uri, 404),
      );
      expect(
        await isUrlAccessible('https://example.com', dio: notFoundDio),
        isFalse,
      );

      final throwingDio = _FakeDio(
        onHeadUri: (uri) => Future.error(
          DioException(requestOptions: RequestOptions(path: uri.toString())),
        ),
      );
      expect(
        await isUrlAccessible('https://example.com', dio: throwingDio),
        isFalse,
      );
    });

    test('returns false when URL cannot be parsed', () async {
      final dio = _FakeDio();
      expect(await isUrlAccessible('::not-a-uri::', dio: dio), isFalse);
    });
  });
}
