import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_playground/data/model/livekit_token_response.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
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
  group('LiveKitTokenRepository', () {
    test('fetchToken calls generateLiveKitToken and parses response', () async {
      String? calledFunctionName;
      Object? calledParameters;

      final functions = _FakeFirebaseFunctions((name) {
        calledFunctionName = name;
        return _FakeHttpsCallable((parameters) async {
          calledParameters = parameters;
          return <Object?, Object?>{
            'url': 'wss://livekit.example.com',
            'roomName': 'demo-room',
            'token': 'signed-jwt',
            'identity': 'uid-42',
            'expiresAt': 1800000000,
          };
        });
      });

      final repository = LiveKitTokenRepository(functions);
      final response = await repository.fetchToken(roomName: 'demo-room');

      expect(calledFunctionName, 'generateLiveKitToken');
      expect(calledParameters, {'roomName': 'demo-room'});
      expect(
        response,
        const LiveKitTokenResponse(
          url: 'wss://livekit.example.com',
          roomName: 'demo-room',
          token: 'signed-jwt',
          identity: 'uid-42',
          expiresAt: 1800000000,
        ),
      );
    });
  });
}
