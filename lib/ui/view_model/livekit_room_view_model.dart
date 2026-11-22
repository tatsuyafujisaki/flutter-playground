import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'livekit_room_view_model.g.dart';

/// Immutable UI state for a LiveKit room session.
class const LiveKitRoomState({
  /// The active LiveKit [Room], or `null` when disconnected.
  final Room? room,

  /// Whether a join attempt is currently in progress.
  final bool isJoining = false,

  /// Whether the local participant has joined [room].
  final bool isJoined = false,

  /// The active local camera facing direction.
  final CameraPosition cameraPosition = .front,

  /// An optional status or error message to show in the UI.
  final String? statusMessage,
}) {
  /// Creates a [LiveKitRoomState].
  this;

  /// Returns a copy of this state with the provided fields updated.
  LiveKitRoomState copyWith({
    Room? Function()? room,
    bool? isJoining,
    bool? isJoined,
    CameraPosition? cameraPosition,
    String? Function()? statusMessage,
  }) => LiveKitRoomState(
    room: room != null ? room() : this.room,
    isJoining: isJoining ?? this.isJoining,
    isJoined: isJoined ?? this.isJoined,
    cameraPosition: cameraPosition ?? this.cameraPosition,
    statusMessage: statusMessage != null ? statusMessage() : this.statusMessage,
  );
}

/// Returns the active unmuted camera [VideoTrack] for [participant], falling
/// back to any other unmuted video track if no camera track is published.
VideoTrack? findCameraTrack(Participant<TrackPublication> participant) {
  VideoTrack? fallback;
  for (final publication in participant.videoTrackPublications) {
    if (publication.muted) {
      continue;
    }
    if (publication.track case final VideoTrack track) {
      if (publication.source == .camera) {
        return track;
      }
      fallback ??= track;
    }
  }
  return fallback;
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
      state = state.copyWith(statusMessage: () => 'Please enter a room name.');
      return;
    }

    state = state.copyWith(isJoining: true, statusMessage: () => null);

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
          statusMessage: () =>
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
      state = state.copyWith(room: () => room, cameraPosition: .front);

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
        room: () => room,
        isJoining: false,
        isJoined: true,
        statusMessage: () => publishWarning,
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
  Future<void> toggleAudio() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    try {
      await localParticipant.setMicrophoneEnabled(
        !localParticipant.isMicrophoneEnabled(),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to toggle microphone',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        statusMessage: () => 'Failed to toggle microphone: $error',
      );
    }
  }

  /// Toggles the local camera state.
  Future<void> toggleVideo() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    try {
      await localParticipant.setCameraEnabled(
        !localParticipant.isCameraEnabled(),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to toggle camera',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        statusMessage: () => 'Failed to toggle camera: $error',
      );
    }
  }

  /// Switches between the front and back cameras for the local video track.
  Future<void> switchCamera() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    final cameraTrack = findCameraTrack(localParticipant);
    if (cameraTrack is! LocalVideoTrack) {
      return;
    }
    final nextPosition = state.cameraPosition.switched();
    try {
      await cameraTrack.setCameraPosition(nextPosition);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(cameraPosition: nextPosition);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to switch camera',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        statusMessage: () => 'Failed to switch camera: $error',
      );
    }
  }
}
