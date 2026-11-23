import 'package:dio/dio.dart';
import 'package:flutter_playground/data/utils/network_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fake_dio.dart';

Response<void> _statusResponse(Uri uri, int statusCode) => Response<void>(
  requestOptions: RequestOptions(path: uri.toString()),
  statusCode: statusCode,
);

void main() {
  group('isUrlAccessible', () {
    test(
      'returns true for 2xx HEAD response without closing passed Dio',
      () async {
        final dio = FakeDio(
          onHeadUri: (uri, _) async => _statusResponse(uri, 200),
        );

        expect(await isUrlAccessible('https://example.com', dio: dio), isTrue);
        expect(dio.isClosed, isFalse);
      },
    );

    test('falls back to GET when HEAD returns 405', () async {
      var getCalled = false;
      final dio = FakeDio(
        onHeadUri: (uri, _) async => _statusResponse(uri, 405),
        onGetUri: (uri, _) async {
          getCalled = true;
          return _statusResponse(uri, 204);
        },
      );

      expect(await isUrlAccessible('https://example.com', dio: dio), isTrue);
      expect(getCalled, isTrue);
    });

    test('returns false for non-2xx status codes and exceptions', () async {
      final notFoundDio = FakeDio(
        onHeadUri: (uri, _) async => _statusResponse(uri, 404),
      );
      expect(
        await isUrlAccessible('https://example.com', dio: notFoundDio),
        isFalse,
      );

      final throwingDio = FakeDio(
        onHeadUri: (uri, _) => Future.error(
          DioException(requestOptions: RequestOptions(path: uri.toString())),
        ),
      );
      expect(
        await isUrlAccessible('https://example.com', dio: throwingDio),
        isFalse,
      );
    });

    test('returns false when URL cannot be parsed', () async {
      final dio = FakeDio();
      expect(await isUrlAccessible('::not-a-uri::', dio: dio), isFalse);
    });
  });
}
