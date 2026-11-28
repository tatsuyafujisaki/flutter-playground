import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'livekit_room_view_model.freezed.dart';
part 'livekit_room_view_model.g.dart';

/// The kinds of status that a LiveKit room session reports to the user.
enum LiveKitRoomStatusType {
  /// The room name is empty.
  roomNameRequired,

  /// Camera or microphone permission is denied.
  permissionsRequired,

  /// The room disconnected unexpectedly.
  disconnected,

  /// The camera couldn't be enabled after joining.
  cameraUnavailable,

  /// The microphone couldn't be enabled after joining.
  microphoneUnavailable,

  /// The LiveKit token couldn't be fetched.
  tokenFetchFailed,

  /// Joining the room failed.
  joinFailed,

  /// Muting or unmuting the microphone failed.
  toggleMicrophoneFailed,

  /// Turning the camera on or off failed.
  toggleCameraFailed,

  /// Switching between cameras failed.
  switchCameraFailed,
}

/// A status that the UI localizes and shows to the user.
@freezed
sealed class LiveKitRoomStatus with _$LiveKitRoomStatus {
  /// Creates a [LiveKitRoomStatus] of [type] with an optional untranslated
  /// [detail], such as an error description.
  const factory(LiveKitRoomStatusType type, [String? detail]) =
      _LiveKitRoomStatus;
}

/// Immutable UI state for a LiveKit room session.
@freezed
sealed class LiveKitRoomState with _$LiveKitRoomState {
  /// Creates a [LiveKitRoomState].
  const factory({
    /// The active LiveKit [Room], or `null` when disconnected.
    Room? room,

    /// Whether a join attempt is currently in progress.
    @Default(false) bool isJoining,

    /// The active local camera facing direction.
    @Default(CameraPosition.front) CameraPosition cameraPosition,

    /// An optional status or error to show in the UI.
    LiveKitRoomStatus? status,
  }) = _LiveKitRoomState;

  const new _();

  /// Whether the local participant has joined [room].
  bool get isJoined => room != null && !isJoining;
}

/// Returns the active unmuted camera [VideoTrack] for [participant], falling
/// back to any other unmuted video track if no camera track is published.
VideoTrack? findCameraTrack(Participant<TrackPublication> participant) {
  final active = [
    for (final publication in participant.videoTrackPublications)
      if (!publication.muted)
        if (publication.track case final VideoTrack track)
          (publication.source, track),
  ];
  return active.firstWhereOrNull((entry) => entry.$1 == .camera)?.$2 ??
      active.firstOrNull?.$2;
}

/// Requests camera, microphone, and (on Android) Bluetooth permissions needed
/// for a LiveKit call.
@riverpod
Future<bool> Function() liveKitPermissionRequester(Ref ref) => () async {
  if (kIsWeb) {
    return true;
  }
  final statuses = await [Permission.camera, Permission.microphone].request();
  final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
  final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
  if (defaultTargetPlatform == .android) {
    await Permission.bluetoothConnect.request();
  }
  return cameraGranted && micGranted;
};

/// A Riverpod notifier that manages LiveKit room lifecycle, token retrieval,
/// and local media controls.
@riverpod
class LiveKitRoomViewModel extends _$LiveKitRoomViewModel {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;

  @override
  LiveKitRoomState build() {
    ref.onDispose(() => unawaited(_releaseRoom()));
    return const LiveKitRoomState();
  }

  Future<bool> _isRoomStale(Room room) async {
    if (ref.mounted && _room == room) {
      return false;
    }
    if (_room == room) {
      await _releaseRoom();
    }
    return true;
  }

  /// Joins the LiveKit room named [rawRoomName] after checking permissions and
  /// fetching a token from Cloud Functions for Firebase.
  Future<void> joinRoom(String rawRoomName) async {
    if (state.isJoining) {
      return;
    }
    final roomName = rawRoomName.trim();
    if (roomName.isEmpty) {
      state = state.copyWith(status: const .new(.roomNameRequired));
      return;
    }

    state = state.copyWith(isJoining: true, status: null);

    try {
      final hasPermissions = await ref.read(
        liveKitPermissionRequesterProvider,
      )();
      if (!ref.mounted) {
        return;
      }
      if (!hasPermissions) {
        state = state.copyWith(
          isJoining: false,
          status: const .new(.permissionsRequired),
        );
        return;
      }

      await ref.read(authViewModelProvider.notifier).signInAnonymously();
      if (!ref.mounted) {
        return;
      }
      final tokenResponse = await ref
          .read(liveKitTokenRepositoryProvider)
          .fetchToken(roomName: roomName);
      if (!ref.mounted) {
        return;
      }

      await _releaseRoom();
      if (!ref.mounted) {
        return;
      }

      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );
      final roomListener = room.createListener()
        ..on<RoomDisconnectedEvent>((event) {
          developer.log('Disconnected from LiveKit room: ${event.reason}');
          if (_room == room) {
            unawaited(_releaseRoom());
          }
          if (!ref.mounted) {
            return;
          }
          state = LiveKitRoomState(
            status: switch (event.reason) {
              null || .clientInitiated => null,
              final reason => .new(.disconnected, reason.name),
            },
          );
        });

      _room = room;
      _roomListener = roomListener;

      await room.connect(tokenResponse.url, tokenResponse.token);
      if (await _isRoomStale(room)) {
        return;
      }

      LiveKitRoomStatus? publishWarning;
      try {
        await room.localParticipant?.setCameraEnabled(true);
      } on Exception catch (error, stackTrace) {
        developer.log(
          'Failed to enable camera',
          error: error,
          stackTrace: stackTrace,
        );
        publishWarning = .new(.cameraUnavailable, '$error');
      }
      if (await _isRoomStale(room)) {
        return;
      }

      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
      } on Exception catch (error, stackTrace) {
        developer.log(
          'Failed to enable microphone',
          error: error,
          stackTrace: stackTrace,
        );
        publishWarning ??= .new(.microphoneUnavailable, '$error');
      }
      if (await _isRoomStale(room)) {
        return;
      }

      state = state.copyWith(
        room: room,
        isJoining: false,
        cameraPosition: .front,
        status: publishWarning,
      );
    } on FirebaseFunctionsException catch (error, stackTrace) {
      developer.log(
        'Failed to fetch LiveKit token',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseRoom();
      if (!ref.mounted) {
        return;
      }
      state = LiveKitRoomState(
        status: .new(.tokenFetchFailed, switch (error.message) {
          final message? => '${error.code}: $message',
          null => error.code,
        }),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to join LiveKit room',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseRoom();
      if (!ref.mounted) {
        return;
      }
      state = LiveKitRoomState(status: .new(.joinFailed, '$error'));
    }
  }

  /// Disconnects from the current room and resets session state.
  Future<void> leaveRoom() async {
    await _releaseRoom();
    if (!ref.mounted) {
      return;
    }
    state = const LiveKitRoomState();
  }

  Future<void> _releaseRoom() async {
    final room = _room;
    final roomListener = _roomListener;
    _room = null;
    _roomListener = null;
    try {
      await roomListener?.dispose();
      if (room != null) {
        await room.disconnect();
        await room.dispose();
      }
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to release LiveKit room',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Toggles the local microphone state.
  Future<void> toggleAudio() => _runParticipantAction(
    .toggleMicrophoneFailed,
    (participant) =>
        participant.setMicrophoneEnabled(!participant.isMicrophoneEnabled()),
  );

  /// Toggles the local camera state.
  Future<void> toggleVideo() => _runParticipantAction(
    .toggleCameraFailed,
    (participant) =>
        participant.setCameraEnabled(!participant.isCameraEnabled()),
  );

  /// Switches between the front and back cameras for the local video track.
  Future<void> switchCamera() =>
      _runParticipantAction(.switchCameraFailed, (participant) async {
        final cameraTrack = findCameraTrack(participant);
        if (cameraTrack is! LocalVideoTrack) {
          return;
        }
        final nextPosition = state.cameraPosition.switched();
        await cameraTrack.setCameraPosition(nextPosition);
        if (ref.mounted) {
          state = state.copyWith(cameraPosition: nextPosition);
        }
      });

  Future<void> _runParticipantAction(
    LiveKitRoomStatusType failureType,
    Future<void> Function(LocalParticipant participant) action,
  ) async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    try {
      await action(localParticipant);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'LiveKit participant action failed: ${failureType.name}',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(status: .new(failureType, '$error'));
    }
  }
}
