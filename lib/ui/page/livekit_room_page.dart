import 'dart:async';

import 'package:flutter_playground/ui/view_model/livekit_room_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_ui/material_ui.dart';

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

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: _defaultRoomName);
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveKitRoomViewModelProvider);
    final notifier = ref.read(liveKitRoomViewModelProvider.notifier);
    final room = state.room;

    return Scaffold(
      appBar: AppBar(title: const Text('LiveKit')),
      body: SafeArea(
        child: state.isJoined && room != null
            ? _CallView(
                room: room,
                fallbackRoomName: _roomController.text.trim(),
                statusMessage: state.statusMessage,
                onToggleAudio: () => unawaited(notifier.toggleAudio()),
                onToggleVideo: () => unawaited(notifier.toggleVideo()),
                onSwitchCamera: () => unawaited(notifier.switchCamera()),
                onLeave: () => unawaited(notifier.leaveRoom()),
              )
            : _SetupView(
                roomController: _roomController,
                isJoining: state.isJoining,
                statusMessage: state.statusMessage,
                onJoin: () =>
                    unawaited(notifier.joinRoom(_roomController.text)),
              ),
      ),
    );
  }
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
    final videoTrack = findCameraTrack(participant);
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: room,
    builder: (context, _) {
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
    },
  );
}

class const _LocalPreview({required final Room room}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: room,
    builder: (context, _) {
      final localParticipant = room.localParticipant;
      final videoTrack = localParticipant != null
          ? findCameraTrack(localParticipant)
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
    },
  );
}

class const _CallControls({
  required final Room room,
  required final VoidCallback onToggleAudio,
  required final VoidCallback onToggleVideo,
  required final VoidCallback onSwitchCamera,
  required final VoidCallback onLeave,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: room,
    builder: (context, _) {
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
    },
  );
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
