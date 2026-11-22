import 'package:freezed_annotation/freezed_annotation.dart';

part 'livekit_token_response.freezed.dart';
part 'livekit_token_response.g.dart';

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
