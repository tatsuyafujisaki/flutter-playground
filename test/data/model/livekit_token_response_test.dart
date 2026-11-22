import 'package:flutter_playground/data/model/livekit_token_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveKitTokenResponse', () {
    test('round-trips through JSON serialization', () {
      const response = LiveKitTokenResponse(
        url: 'wss://example.livekit.cloud',
        roomName: 'test-room',
        token: 'jwt-token',
        identity: 'user-123',
        expiresAt: 1700000000,
      );
      final json = response.toJson();

      expect(json, {
        'url': 'wss://example.livekit.cloud',
        'roomName': 'test-room',
        'token': 'jwt-token',
        'identity': 'user-123',
        'expiresAt': 1700000000,
      });
      expect(LiveKitTokenResponse.fromJson(json), response);
    });
  });
}
