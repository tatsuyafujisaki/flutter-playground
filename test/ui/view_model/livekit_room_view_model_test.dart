import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
import 'package:flutter_playground/ui/view_model/livekit_room_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends Fake implements User;

class _FakeAuthRepository(@override final User? currentUser)
    implements AuthRepository {
  @override
  Future<UserCredential> signInAnonymously() =>
      throw UnimplementedError('Not expected to sign in.');
}

class _FakeLiveKitTokenRepository(
  final Future<LiveKitTokenResponse> Function(String roomName) onFetchToken,
) implements LiveKitTokenRepository {
  @override
  Future<LiveKitTokenResponse> fetchToken({required String roomName}) =>
      onFetchToken(roomName);
}

void main() {
  group('LiveKitRoomViewModel', () {
    test('reports validation error when room name is blank', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(liveKitRoomViewModelProvider.notifier)
          .joinRoom('   ');

      final state = container.read(liveKitRoomViewModelProvider);
      expect(state.isJoining, isFalse);
      expect(state.isJoined, isFalse);
      expect(state.statusMessage, 'Please enter a room name.');
    });

    test(
      'reports error when camera or microphone permission is denied',
      () async {
        final container = ProviderContainer(
          overrides: [
            liveKitPermissionRequesterProvider.overrideWithValue(
              () async => false,
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(liveKitRoomViewModelProvider.notifier)
            .joinRoom('test-room');

        final state = container.read(liveKitRoomViewModelProvider);
        expect(state.isJoining, isFalse);
        expect(state.isJoined, isFalse);
        expect(
          state.statusMessage,
          'Camera and microphone permissions are required to join a call.',
        );
      },
    );

    test('formats FirebaseFunctionsException from token fetch', () async {
      final container = ProviderContainer(
        overrides: [
          liveKitPermissionRequesterProvider.overrideWithValue(
            () async => true,
          ),
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(_FakeUser()),
          ),
          liveKitTokenRepositoryProvider.overrideWithValue(
            _FakeLiveKitTokenRepository(
              (_) => Future.error(
                FirebaseFunctionsException(
                  code: 'permission-denied',
                  message: 'Access denied',
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(liveKitRoomViewModelProvider.notifier)
          .joinRoom('test-room');

      final state = container.read(liveKitRoomViewModelProvider);
      expect(state.isJoining, isFalse);
      expect(state.isJoined, isFalse);
      expect(state.room, isNull);
      expect(
        state.statusMessage,
        'Failed to fetch token (permission-denied): Access denied',
      );
    });
  });
}
