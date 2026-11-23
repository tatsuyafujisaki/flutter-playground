import 'package:dio/dio.dart';
import 'package:flutter_playground/data/utils/download_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fake_dio.dart';

void main() {
  group('download_utils', () {
    test('downloadBinaryFile returns bytes with ResponseType.bytes', () async {
      final dio = FakeDio(
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
      final dio = FakeDio(
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
      final dio = FakeDio(
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
