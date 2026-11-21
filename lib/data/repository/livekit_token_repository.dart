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
class const LiveKitTokenResponse({
  /// The WebSocket URL of the LiveKit Cloud server.
  required final String url,

  /// The room name that [token] grants access to.
  required final String roomName,

  /// The generated LiveKit access token (JWT).
  required final String token,

  /// The participant identity bound to [token].
  required final String identity,

  /// The Unix timestamp (in seconds) when [token] expires.
  required final int expiresAt,
}) {
  /// Creates a [LiveKitTokenResponse].
  this;
}

/// A repository that fetches LiveKit access tokens from Cloud Functions for
/// Firebase.
class const LiveKitTokenRepository(final FirebaseFunctions _functions) {
  /// Creates a [LiveKitTokenRepository] with the given [FirebaseFunctions]
  /// instance.
  this;

  /// Requests a freshly generated LiveKit access token for [roomName].
  Future<LiveKitTokenResponse> fetchToken({required String roomName}) async {
    final callable = _functions.httpsCallable('generateLiveKitToken');
    final result = await callable.call<Map<Object?, Object?>>({
      'roomName': roomName,
    });
    return switch (result.data) {
      {
        'url': final String url,
        'roomName': final String resolvedRoomName,
        'token': final String token,
        'identity': final String identity,
        'expiresAt': final num expiresAt,
      } =>
        LiveKitTokenResponse(
          url: url,
          roomName: resolvedRoomName,
          token: token,
          identity: identity,
          expiresAt: expiresAt.toInt(),
        ),
      _ => throw const FormatException(
        'Unexpected response format from generateLiveKitToken.',
      ),
    };
  }
}
