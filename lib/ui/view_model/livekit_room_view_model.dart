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

/// Immutable UI state for a LiveKit room session.
@freezed
sealed class LiveKitRoomState with _$LiveKitRoomState {
  /// Creates a [LiveKitRoomState].
  const factory({
    /// The active LiveKit [Room], or `null` when disconnected.
    Room? room,

    /// Whether a join attempt is currently in progress.
    @Default(false) bool isJoining,

    /// Whether the local participant has joined [room].
    @Default(false) bool isJoined,

    /// The active local camera facing direction.
    @Default(CameraPosition.front) CameraPosition cameraPosition,

    /// An optional status or error message to show in the UI.
    String? statusMessage,
  }) = _LiveKitRoomState;
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
      state = state.copyWith(statusMessage: 'Please enter a room name.');
      return;
    }

    state = state.copyWith(isJoining: true, statusMessage: null);

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
          statusMessage:
              'Camera and microphone permissions are required to join a call.',
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
            statusMessage:
                event.reason != null && event.reason != .clientInitiated
                ? 'Disconnected: ${event.reason!.name}'
                : null,
          );
        });

      _room = room;
      _roomListener = roomListener;
      state = state.copyWith(room: room, cameraPosition: .front);

      await room.connect(tokenResponse.url, tokenResponse.token);
      if (await _isRoomStale(room)) {
        return;
      }

      String? publishWarning;
      try {
        await room.localParticipant?.setCameraEnabled(true);
      } on Exception catch (error, stackTrace) {
        developer.log(
          'Failed to enable camera',
          error: error,
          stackTrace: stackTrace,
        );
        publishWarning = 'Camera unavailable: $error';
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
        publishWarning ??= 'Microphone unavailable: $error';
      }
      if (await _isRoomStale(room)) {
        return;
      }

      state = state.copyWith(
        room: room,
        isJoining: false,
        isJoined: true,
        statusMessage: publishWarning,
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
        statusMessage:
            'Failed to fetch token (${error.code}): '
            '${error.message ?? 'Unknown error'}',
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
      state = LiveKitRoomState(statusMessage: 'Failed to join room: $error');
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
    'Failed to toggle microphone',
    (participant) =>
        participant.setMicrophoneEnabled(!participant.isMicrophoneEnabled()),
  );

  /// Toggles the local camera state.
  Future<void> toggleVideo() => _runParticipantAction(
    'Failed to toggle camera',
    (participant) =>
        participant.setCameraEnabled(!participant.isCameraEnabled()),
  );

  /// Switches between the front and back cameras for the local video track.
  Future<void> switchCamera() =>
      _runParticipantAction('Failed to switch camera', (participant) async {
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
    String failureMessage,
    Future<void> Function(LocalParticipant participant) action,
  ) async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    try {
      await action(localParticipant);
    } on Exception catch (error, stackTrace) {
      developer.log(failureMessage, error: error, stackTrace: stackTrace);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(statusMessage: '$failureMessage: $error');
    }
  }
}
