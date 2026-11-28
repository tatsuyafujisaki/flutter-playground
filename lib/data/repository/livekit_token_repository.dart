import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_playground/data/model/livekit_token_response.dart';
import 'package:flutter_playground/data/provider/firebase_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'livekit_token_repository.g.dart';

const _generateTokenFunctionName = 'generateLiveKitToken';

/// Provides the singleton [LiveKitTokenRepository] instance.
@Riverpod(keepAlive: true)
LiveKitTokenRepository liveKitTokenRepository(Ref ref) =>
    LiveKitTokenRepository(ref.watch(firebaseFunctionsProvider));

/// A repository that fetches LiveKit access tokens from Cloud Functions for
/// Firebase.
class const LiveKitTokenRepository(final FirebaseFunctions _functions) {
  /// Creates a [LiveKitTokenRepository] with the given [FirebaseFunctions]
  /// instance.
  this;

  /// Requests a freshly generated LiveKit access token for [roomName].
  Future<LiveKitTokenResponse> fetchToken({required String roomName}) async {
    final callable = _functions.httpsCallable(_generateTokenFunctionName);
    final result = await callable.call<Map<Object?, Object?>>({
      'roomName': roomName,
    });
    return LiveKitTokenResponse.fromJson(
      Map<String, dynamic>.from(result.data),
    );
  }
}
