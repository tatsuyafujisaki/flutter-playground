import 'package:cloud_functions/cloud_functions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'livekit_token_repository.freezed.dart';
part 'livekit_token_repository.g.dart';

/// Provides the singleton [LiveKitTokenRepository] instance.
@Riverpod(keepAlive: true)
LiveKitTokenRepository liveKitTokenRepository(Ref ref) =>
    LiveKitTokenRepository(
      FirebaseFunctions.instanceFor(region: 'asia-northeast1'),
    );

/// The response returned by the `generateLiveKitToken` Cloud Function.
@freezed
sealed class LiveKitTokenResponse with _$LiveKitTokenResponse {
  /// Creates a [LiveKitTokenResponse].
  const factory({
    /// The WebSocket URL of the LiveKit Cloud server.
    required String url,

    /// The room name that [token] grants access to.
    required String roomName,

    /// The generated LiveKit access token (JWT).
    required String token,

    /// The participant identity bound to [token].
    required String identity,

    /// The Unix timestamp (in seconds) when [token] expires.
    required int expiresAt,
  }) = _LiveKitTokenResponse;

  /// Creates a [LiveKitTokenResponse] from a JSON map.
  factory fromJson(Map<String, dynamic> json) =>
      _$LiveKitTokenResponseFromJson(json);
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
    return LiveKitTokenResponse.fromJson(
      Map<String, dynamic>.from(result.data),
    );
  }
}
