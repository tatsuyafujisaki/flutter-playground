import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'livekit_token_repository.g.dart';

/// Provides the singleton [LiveKitTokenRepository] instance.
@Riverpod(keepAlive: true)
LiveKitTokenRepository liveKitTokenRepository(Ref ref) =>
    LiveKitTokenRepository(
      FirebaseFunctions.instanceFor(region: 'asia-northeast1'),
    );

/// The response returned by the `generateLiveKitToken` Cloud Function.
class LiveKitTokenResponse {
  /// Creates a [LiveKitTokenResponse].
  const new({
    required this.url,
    required this.roomName,
    required this.token,
    required this.identity,
    required this.expiresAt,
  });

  /// The WebSocket URL of the LiveKit Cloud server.
  final String url;

  /// The room name that [token] grants access to.
  final String roomName;

  /// The generated LiveKit access token (JWT).
  final String token;

  /// The participant identity bound to [token].
  final String identity;

  /// The Unix timestamp (in seconds) when [token] expires.
  final int expiresAt;
}

/// A repository that fetches LiveKit access tokens from Cloud Functions for
/// Firebase.
class LiveKitTokenRepository {
  /// Creates a [LiveKitTokenRepository] with the given [FirebaseFunctions]
  /// instance.
  const new(this._functions);

  final FirebaseFunctions _functions;

  /// Requests a freshly generated LiveKit access token for [roomName].
  Future<LiveKitTokenResponse> fetchToken({required String roomName}) async {
    final callable = _functions.httpsCallable('generateLiveKitToken');
    final result = await callable.call<Map<Object?, Object?>>({
      'roomName': roomName,
    });
    final data = result.data;
    final url = data['url'];
    final resolvedRoomName = data['roomName'];
    final token = data['token'];
    final identity = data['identity'];
    final expiresAt = data['expiresAt'];

    if (url is! String ||
        resolvedRoomName is! String ||
        token is! String ||
        identity is! String ||
        expiresAt is! num) {
      throw const FormatException(
        'Unexpected response format from generateLiveKitToken.',
      );
    }

    return LiveKitTokenResponse(
      url: url,
      roomName: resolvedRoomName,
      token: token,
      identity: identity,
      expiresAt: expiresAt.toInt(),
    );
  }
}
