import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agora_token_repository.g.dart';

/// Provides the singleton [AgoraTokenRepository] instance.
@Riverpod(keepAlive: true)
AgoraTokenRepository agoraTokenRepository(Ref ref) => AgoraTokenRepository(
  FirebaseFunctions.instanceFor(region: 'asia-northeast1'),
);

/// The response returned by the `generateAgoraToken` Cloud Function.
class AgoraTokenResponse {
  /// Creates an [AgoraTokenResponse].
  const new({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.uid,
    required this.expiresAt,
  });

  /// The Agora App ID associated with [token].
  final String appId;

  /// The channel name that [token] grants access to.
  final String channelName;

  /// The generated Agora RTC token.
  final String token;

  /// The numeric UID bound to [token].
  final int uid;

  /// The Unix timestamp (in seconds) when [token] expires.
  final int expiresAt;
}

/// A repository that fetches Agora RTC tokens from Cloud Functions for
/// Firebase.
class AgoraTokenRepository {
  /// Creates an [AgoraTokenRepository] with the given [FirebaseFunctions]
  /// instance.
  const new(this._functions);

  final FirebaseFunctions _functions;

  /// Requests a freshly generated Agora RTC token for [channelName] and [uid].
  Future<AgoraTokenResponse> fetchToken({
    required String channelName,
    int uid = 0,
  }) async {
    final callable = _functions.httpsCallable('generateAgoraToken');
    final result = await callable.call<Map<Object?, Object?>>({
      'channelName': channelName,
      'uid': uid,
    });
    final data = result.data;
    final appId = data['appId'];
    final resolvedChannelName = data['channelName'];
    final token = data['token'];
    final resolvedUid = data['uid'];
    final expiresAt = data['expiresAt'];

    if (appId is! String ||
        resolvedChannelName is! String ||
        token is! String ||
        resolvedUid is! num ||
        expiresAt is! num) {
      throw const FormatException(
        'Unexpected response format from generateAgoraToken.',
      );
    }

    return AgoraTokenResponse(
      appId: appId,
      channelName: resolvedChannelName,
      token: token,
      uid: resolvedUid.toInt(),
      expiresAt: expiresAt.toInt(),
    );
  }
}
