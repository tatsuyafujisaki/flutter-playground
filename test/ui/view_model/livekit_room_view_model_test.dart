import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/model/livekit_token_response.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
import 'package:flutter_playground/ui/view_model/livekit_room_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';

class _FakeUser extends Fake implements User;

class _FakeVideoTrack extends Fake implements VideoTrack;

class _FakeTrackPublication({
  @override required final TrackSource source,
  @override final bool muted = false,
  @override final Track? track,
}) extends Fake implements TrackPublication<Track>;

class _FakeParticipant(
  @override final List<TrackPublication<Track>> videoTrackPublications,
) extends Fake implements Participant<TrackPublication<Track>>;

class _FakeAuthRepository(@override final User? currentUser)
    extends Fake
    implements AuthRepository;

class _FakeLiveKitTokenRepository(
  final Future<LiveKitTokenResponse> Function(String roomName) onFetchToken,
) extends Fake implements LiveKitTokenRepository {
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

  group('findCameraTrack', () {
    test('prefers unmuted camera track over other video tracks', () {
      final screenTrack = _FakeVideoTrack();
      final cameraTrack = _FakeVideoTrack();
      final participant = _FakeParticipant([
        _FakeTrackPublication(source: .screenShareVideo, track: screenTrack),
        _FakeTrackPublication(source: .camera, track: cameraTrack),
      ]);

      expect(findCameraTrack(participant), same(cameraTrack));
    });

    test('falls back to unmuted non-camera track when camera is muted', () {
      final mutedCameraTrack = _FakeVideoTrack();
      final screenTrack = _FakeVideoTrack();
      final participant = _FakeParticipant([
        _FakeTrackPublication(
          source: .camera,
          muted: true,
          track: mutedCameraTrack,
        ),
        _FakeTrackPublication(source: .screenShareVideo, track: screenTrack),
      ]);

      expect(findCameraTrack(participant), same(screenTrack));
    });

    test('returns null when no unmuted video tracks exist', () {
      final mutedCameraTrack = _FakeVideoTrack();
      final participant = _FakeParticipant([
        _FakeTrackPublication(
          source: .camera,
          muted: true,
          track: mutedCameraTrack,
        ),
      ]);

      expect(findCameraTrack(participant), isNull);
    });
  });
}
