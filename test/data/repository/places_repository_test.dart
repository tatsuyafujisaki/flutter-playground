import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_playground/data/model/chain_cafe.dart';
import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpsCallableResult<T>(@override final T data)
    extends Fake
    implements HttpsCallableResult<T>;

class _FakeHttpsCallable(
  final Future<Map<Object?, Object?>> Function(Object? parameters) onCall,
) extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([Object? parameters]) async {
    final data = await onCall(parameters);
    return _FakeHttpsCallableResult<T>(data as T);
  }
}

class _FakeFirebaseFunctions(
  final HttpsCallable Function(String name) onHttpsCallable,
) extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      onHttpsCallable(name);
}

void main() {
  group('PlacesRepository', () {
    test('searchNearbyChainCafes calls searchNearbyChainCafes and parses the '
        'response', () async {
      String? calledFunctionName;
      Object? calledParameters;

      final functions = _FakeFirebaseFunctions((name) {
        calledFunctionName = name;
        return _FakeHttpsCallable((parameters) async {
          calledParameters = parameters;
          // The platform channel returns untyped nested maps and may decode
          // whole-number doubles as integers.
          return <Object?, Object?>{
            'places': <Object?>[
              <Object?, Object?>{
                'id': 'place_1',
                'name': 'Starbucks Tokyo Station',
                'latitude': 35.6812,
                'longitude': 139.7671,
                'websiteUri': 'https://store.starbucks.co.jp/detail-123/',
                'googleMapsUri': 'https://maps.google.com/?cid=12345',
              },
              <Object?, Object?>{
                'id': 'place_2',
                'name': 'Doutor Coffee',
                'latitude': 35,
                'longitude': 139,
                'websiteUri': 'https://shop.doutor.co.jp/detail/1',
              },
            ],
          };
        });
      });

      final cafes = await PlacesRepository(functions).searchNearbyChainCafes(
        latitude: 35.6812,
        longitude: 139.7671,
        languageCode: 'ja',
      );

      expect(calledFunctionName, 'searchNearbyChainCafes');
      expect(calledParameters, {
        'latitude': 35.6812,
        'longitude': 139.7671,
        'languageCode': 'ja',
      });
      expect(cafes, const [
        ChainCafe(
          id: 'place_1',
          name: 'Starbucks Tokyo Station',
          latitude: 35.6812,
          longitude: 139.7671,
          websiteUri: 'https://store.starbucks.co.jp/detail-123/',
          googleMapsUri: 'https://maps.google.com/?cid=12345',
        ),
        ChainCafe(
          id: 'place_2',
          name: 'Doutor Coffee',
          latitude: 35,
          longitude: 139,
          websiteUri: 'https://shop.doutor.co.jp/detail/1',
        ),
      ]);
    });

    test('searchNearbyChainCafes omits languageCode when it is null', () async {
      Object? calledParameters;

      final functions = _FakeFirebaseFunctions(
        (name) => _FakeHttpsCallable((parameters) async {
          calledParameters = parameters;
          return <Object?, Object?>{'places': <Object?>[]};
        }),
      );

      final cafes = await PlacesRepository(functions)
          .searchNearbyChainCafes(latitude: 35.6812, longitude: 139.7671);

      expect(calledParameters, {'latitude': 35.6812, 'longitude': 139.7671});
      expect(cafes, isEmpty);
    });

    test(
      'searchNearbyChainCafes returns an empty list when places is missing',
      () async {
        final functions = _FakeFirebaseFunctions(
          (name) => _FakeHttpsCallable((parameters) async => {}),
        );

        final cafes = await PlacesRepository(functions)
            .searchNearbyChainCafes(latitude: 35.6812, longitude: 139.7671);

        expect(cafes, isEmpty);
      },
    );
  });
}
