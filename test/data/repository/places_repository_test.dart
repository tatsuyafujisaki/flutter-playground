import 'package:dio/dio.dart';
import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fake_dio.dart';

Response<T> _response<T>(String path, T? data, {int statusCode = 200}) =>
    Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: statusCode,
    );

void main() {
  group('PlacesRepository', () {
    late FakeDio dio;
    late PlacesRepository repository;

    setUp(() {
      dio = FakeDio();
      repository = PlacesRepository(
        dio,
        true,
        appRestrictionHeaders: () async => const {},
      );
    });

    test('searchNearbyChainCafes queries Text Search per chain and '
        'deduplicates results', () async {
      final capturedBodies = <Map<String, dynamic>>[];

      dio.onPost = (path, data) async {
        expect(path, '/v1/places:searchText');
        final body = data! as Map<String, dynamic>;
        capturedBodies.add(body);
        final query = body['textQuery'] as String;

        if (query == 'Starbucks') {
          return _response<Map<String, dynamic>>(path, const {
            'places': [
              {
                'id': 'place_1',
                'displayName': {'text': 'Starbucks Tokyo Station'},
                'formattedAddress': '1-9-1 Marunouchi',
                'location': {'latitude': 35.6812, 'longitude': 139.7671},
              },
              {
                'id': 'place_shared',
                'displayName': {'text': 'Shared Cafe'},
                'formattedAddress': '1-9-2 Marunouchi',
                'location': {'latitude': 35.6815, 'longitude': 139.7675},
              },
            ],
          });
        }

        return _response<Map<String, dynamic>>(path, const {
          'places': [
            {
              'id': 'place_shared',
              'displayName': {'text': 'Shared Cafe'},
              'formattedAddress': '1-9-2 Marunouchi',
              'location': {'latitude': 35.6815, 'longitude': 139.7675},
            },
            {
              'id': 'place_2',
              'displayName': {'text': 'Doutor Coffee'},
              'formattedAddress': '1-9-3 Marunouchi',
              'location': {'latitude': 35.6820, 'longitude': 139.7680},
            },
          ],
        });
      };

      final places = await repository.searchNearbyChainCafes(
        latitude: 35.6812,
        longitude: 139.7671,
        chainNames: const ['Starbucks', 'Doutor Coffee'],
        languageCode: 'ja',
      );

      expect(capturedBodies, hasLength(2));
      for (final body in capturedBodies) {
        expect(body['includedType'], 'cafe');
        expect(body['strictTypeFiltering'], isTrue);
        expect(body['languageCode'], 'ja');
        expect(body['pageSize'], 20);
        expect(body['locationRestriction'], isNotNull);
      }

      expect(places.map((p) => p.id), ['place_1', 'place_shared', 'place_2']);
    });

    test(
      'searchNearbyChainCafes returns empty list when chainNames is empty',
      () async {
        var called = false;
        dio.onPost = (path, data) async {
          called = true;
          return _response<Map<String, dynamic>>(path, const {});
        };

        final places = await repository.searchNearbyChainCafes(
          latitude: 35.6812,
          longitude: 139.7671,
          chainNames: const [],
        );

        expect(places, isEmpty);
        expect(called, isFalse);
      },
    );

    test(
      'searchNearbyChainCafes throws StateError when API key is missing',
      () async {
        final repoWithoutKey = PlacesRepository(
          dio,
          false,
          appRestrictionHeaders: () async => const {},
        );

        await expectLater(
          repoWithoutKey.searchNearbyChainCafes(
            latitude: 35.6812,
            longitude: 139.7671,
          ),
          throwsStateError,
        );
      },
    );

    test('getPlaceUri returns websiteUri when available', () async {
      String? capturedPath;
      Options? capturedOptions;

      dio.onGet = (path, options) async {
        capturedPath = path;
        capturedOptions = options;
        return _response<Map<String, dynamic>>(path, const {
          'websiteUri': 'https://store.starbucks.co.jp/detail-123/',
          'googleMapsUri': 'https://maps.google.com/?cid=12345',
        });
      };

      final uri = await repository.getPlaceUri('ChIJ_test_id');

      expect(capturedPath, '/v1/places/ChIJ_test_id');
      expect(
        capturedOptions?.headers?['X-Goog-FieldMask'],
        'websiteUri,googleMapsUri',
      );
      expect(uri, Uri.parse('https://store.starbucks.co.jp/detail-123/'));
    });

    test(
      'getPlaceUri falls back to googleMapsUri when websiteUri is missing',
      () async {
        dio.onGet = (path, options) async => _response<Map<String, dynamic>>(
          path,
          const {'googleMapsUri': 'https://maps.google.com/?cid=12345'},
        );

        final uri = await repository.getPlaceUri('ChIJ_no_website');

        expect(uri, Uri.parse('https://maps.google.com/?cid=12345'));
      },
    );

    test(
      'getPlaceUri returns null for empty placeId or non-HTTP URIs',
      () async {
        var called = false;
        dio.onGet = (path, options) async {
          called = true;
          return _response<Map<String, dynamic>>(path, const {
            'websiteUri': 'javascript:alert(1)',
          });
        };

        expect(await repository.getPlaceUri(''), isNull);
        expect(called, isFalse);

        expect(await repository.getPlaceUri('ChIJ_invalid_scheme'), isNull);
        expect(called, isTrue);
      },
    );

    test('getPlaceUri throws StateError when API key is missing', () async {
      final repoWithoutKey = PlacesRepository(
        dio,
        false,
        appRestrictionHeaders: () async => const {},
      );

      await expectLater(
        repoWithoutKey.getPlaceUri('ChIJ_test_id'),
        throwsStateError,
      );
    });
  });
}
