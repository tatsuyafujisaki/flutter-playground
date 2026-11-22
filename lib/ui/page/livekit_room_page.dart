import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_playground/data/repository/livekit_token_repository.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// A demo page for real-time audio and video calling using `livekit_client`
/// with token authentication backed by Cloud Functions for Firebase.
class const LiveKitRoomPage({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [LiveKitRoomPage].
  this;

  @override
  ConsumerState<LiveKitRoomPage> createState() => _LiveKitRoomPageState();
}

class _LiveKitRoomPageState extends ConsumerState<LiveKitRoomPage> {
  static const _defaultRoomName = String.fromEnvironment(
    'LIVEKIT_ROOM_NAME',
    defaultValue: 'test',
  );

  late final TextEditingController _roomController;

  Room? _room;
  EventsListener<RoomEvent>? _roomListener;

  bool _isJoining = false;
  bool _isJoined = false;
  CameraPosition _cameraPosition = .front;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: _defaultRoomName);
  }

  @override
  void dispose() {
    unawaited(_releaseRoom());
    _roomController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
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
  }

  void _onRoomChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<bool> _isRoomStale(Room room) async {
    if (mounted && _room == room) {
      return false;
    }
    if (_room == room) {
      await _releaseRoom();
    }
    return true;
  }

  Future<void> _joinRoom() async {
    if (_isJoining) {
      return;
    }
    final roomName = _roomController.text.trim();
    if (roomName.isEmpty) {
      setState(() => _statusMessage = 'Please enter a room name.');
      return;
    }

    setState(() {
      _isJoining = true;
      _statusMessage = null;
    });

    try {
      final hasPermissions = await _requestPermissions();
      if (!mounted) {
        return;
      }
      if (!hasPermissions) {
        setState(() {
          _isJoining = false;
          _statusMessage =
              'Camera and microphone permissions are required to join a call.';
        });
        return;
      }

      await ref.read(authViewModelProvider.notifier).signInAnonymously();
      if (!mounted) {
        return;
      }
      final tokenResponse = await ref
          .read(liveKitTokenRepositoryProvider)
          .fetchToken(roomName: roomName);
      if (!mounted) {
        return;
      }

      await _releaseRoom();
      if (!mounted) {
        return;
      }

      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      )..addListener(_onRoomChanged);
      final roomListener = room.createListener()
        ..on<RoomDisconnectedEvent>((event) {
          developer.log('Disconnected from LiveKit room: ${event.reason}');
          if (_room == room) {
            unawaited(_releaseRoom());
          }
          if (!mounted) {
            return;
          }
          setState(() {
            _isJoined = false;
            _isJoining = false;
            _cameraPosition = .front;
            if (event.reason != null && event.reason != .clientInitiated) {
              _statusMessage = 'Disconnected: ${event.reason!.name}';
            }
          });
        });

      _room = room;
      _roomListener = roomListener;
      _cameraPosition = .front;

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

      setState(() {
        _isJoining = false;
        _isJoined = true;
        _statusMessage = publishWarning;
      });
    } on FirebaseFunctionsException catch (error, stackTrace) {
      developer.log(
        'Failed to fetch LiveKit token',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseRoom();
      if (!mounted) {
        return;
      }
      setState(() {
        _isJoining = false;
        _isJoined = false;
        _statusMessage =
            'Failed to fetch token (${error.code}): '
            '${error.message ?? 'Unknown error'}';
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to join LiveKit room',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseRoom();
      if (!mounted) {
        return;
      }
      setState(() {
        _isJoining = false;
        _isJoined = false;
        _statusMessage = 'Failed to join room: $error';
      });
    }
  }

  Future<void> _leaveRoom() async {
    await _releaseRoom();
    if (!mounted) {
      return;
    }
    setState(() {
      _isJoined = false;
      _isJoining = false;
      _cameraPosition = .front;
      _statusMessage = null;
    });
  }

  Future<void> _releaseRoom() async {
    final room = _room;
    final roomListener = _roomListener;
    _room = null;
    _roomListener = null;
    try {
      await roomListener?.dispose();
      if (room != null) {
        room.removeListener(_onRoomChanged);
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

  Future<void> _toggleAudio() async {
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
      if (!mounted) {
        return;
      }
      setState(() => _statusMessage = 'Failed to toggle microphone: $error');
    }
  }

  Future<void> _toggleVideo() async {
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
      if (!mounted) {
        return;
      }
      setState(() => _statusMessage = 'Failed to toggle camera: $error');
    }
  }

  Future<void> _switchCamera() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) {
      return;
    }
    final cameraTrack = _findCameraTrack(localParticipant);
    if (cameraTrack is! LocalVideoTrack) {
      return;
    }
    final nextPosition = _cameraPosition.switched();
    try {
      await cameraTrack.setCameraPosition(nextPosition);
      if (!mounted) {
        return;
      }
      setState(() => _cameraPosition = nextPosition);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to switch camera',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() => _statusMessage = 'Failed to switch camera: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    return Scaffold(
      appBar: AppBar(title: const Text('LiveKit')),
      body: SafeArea(
        child: _isJoined && room != null
            ? _CallView(
                room: room,
                fallbackRoomName: _roomController.text.trim(),
                statusMessage: _statusMessage,
                onToggleAudio: _toggleAudio,
                onToggleVideo: _toggleVideo,
                onSwitchCamera: _switchCamera,
                onLeave: _leaveRoom,
              )
            : _SetupView(
                roomController: _roomController,
                isJoining: _isJoining,
                statusMessage: _statusMessage,
                onJoin: _joinRoom,
              ),
      ),
    );
  }
}

VideoTrack? _findCameraTrack(Participant<TrackPublication> participant) {
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

class const _SetupView({
  required final TextEditingController roomController,
  required final bool isJoining,
  required final String? statusMessage,
  required final VoidCallback onJoin,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const .all(24),
    child: Column(
      crossAxisAlignment: .stretch,
      spacing: 16,
      children: [
        TextField(
          controller: roomController,
          enabled: !isJoining,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            hintText: 'e.g. test',
            border: OutlineInputBorder(),
          ),
        ),
        if (statusMessage case final message?)
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        FilledButton.icon(
          onPressed: isJoining ? null : onJoin,
          icon: isJoining
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.video_call),
          label: Text(isJoining ? 'Joining...' : 'Join Room'),
        ),
      ],
    ),
  );
}

class const _ParticipantTile({required final RemoteParticipant participant})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videoTrack = _findCameraTrack(participant);
    return ColoredBox(
      color: Colors.black87,
      child: videoTrack != null
          ? VideoTrackRenderer(videoTrack, fit: .cover)
          : Center(
              child: Column(
                mainAxisSize: .min,
                spacing: 8,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: Colors.white70,
                  ),
                  Text(
                    participant.identity,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
    );
  }
}

class const _RemoteVideos({
  required final Room room,
  required final String fallbackRoomName,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final remoteParticipants = room.remoteParticipants.values.toList();
    final roomName = room.name ?? fallbackRoomName;
    final localIdentity = room.localParticipant?.identity ?? '-';

    if (remoteParticipants.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            const Icon(Icons.people_outline, size: 48),
            Text(
              'Waiting for remote participant...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Room: $roomName (Identity: $localIdentity)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (remoteParticipants.length == 1) {
      return _ParticipantTile(participant: remoteParticipants.first);
    }

    return GridView.builder(
      padding: const .all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: remoteParticipants.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: .circular(12),
        child: _ParticipantTile(participant: remoteParticipants[index]),
      ),
    );
  }
}

class const _LocalPreview({required final Room room}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localParticipant = room.localParticipant;
    final videoTrack = localParticipant != null
        ? _findCameraTrack(localParticipant)
        : null;
    final isVideoEnabled =
        (localParticipant?.isCameraEnabled() ?? false) && videoTrack != null;

    return SizedBox(
      width: 120,
      height: 160,
      child: ClipRRect(
        borderRadius: .circular(12),
        child: ColoredBox(
          color: Colors.black87,
          child: isVideoEnabled
              ? VideoTrackRenderer(videoTrack, fit: .cover)
              : const Center(
                  child: Icon(Icons.videocam_off, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class const _CallControls({
  required final Room room,
  required final VoidCallback onToggleAudio,
  required final VoidCallback onToggleVideo,
  required final VoidCallback onSwitchCamera,
  required final VoidCallback onLeave,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localParticipant = room.localParticipant;
    final isAudioMuted = !(localParticipant?.isMicrophoneEnabled() ?? false);
    final isVideoMuted = !(localParticipant?.isCameraEnabled() ?? false);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const .symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            IconButton.filledTonal(
              onPressed: onToggleAudio,
              tooltip: isAudioMuted ? 'Unmute microphone' : 'Mute microphone',
              icon: Icon(isAudioMuted ? Icons.mic_off : Icons.mic),
            ),
            IconButton.filledTonal(
              onPressed: onToggleVideo,
              tooltip: isVideoMuted ? 'Turn camera on' : 'Turn camera off',
              icon: Icon(isVideoMuted ? Icons.videocam_off : Icons.videocam),
            ),
            IconButton.filledTonal(
              onPressed: isVideoMuted ? null : onSwitchCamera,
              tooltip: 'Switch camera',
              icon: const Icon(Icons.cameraswitch),
            ),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: onLeave,
              tooltip: 'Leave room',
              icon: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }
}

class const _CallView({
  required final Room room,
  required final String fallbackRoomName,
  required final String? statusMessage,
  required final VoidCallback onToggleAudio,
  required final VoidCallback onToggleVideo,
  required final VoidCallback onSwitchCamera,
  required final VoidCallback onLeave,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: _RemoteVideos(room: room, fallbackRoomName: fallbackRoomName),
      ),
      Positioned(top: 16, right: 16, child: _LocalPreview(room: room)),
      if (statusMessage case final message?)
        Positioned(
          top: 16,
          left: 16,
          right: 152,
          child: Material(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: .circular(8),
            child: Padding(
              padding: const .all(8),
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      Align(
        alignment: .bottomCenter,
        child: _CallControls(
          room: room,
          onToggleAudio: onToggleAudio,
          onToggleVideo: onToggleVideo,
          onSwitchCamera: onSwitchCamera,
          onLeave: onLeave,
        ),
      ),
    ],
  );
}
