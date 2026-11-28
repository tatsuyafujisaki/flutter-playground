import 'dart:async';

import 'package:flutter_playground/l10n/app_localizations.dart';
import 'package:flutter_playground/ui/extension/build_context_extension.dart';
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

  final _roomController = TextEditingController(text: _defaultRoomName);

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveKitRoomViewModelProvider);
    final notifier = ref.read(liveKitRoomViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.liveKitPageTitle)),
      body: SafeArea(
        child: switch (state.room) {
          final room? when state.isJoined => _CallView(
            room: room,
            fallbackRoomName: _roomController.text.trim(),
            status: state.status,
            onToggleAudio: () => unawaited(notifier.toggleAudio()),
            onToggleVideo: () => unawaited(notifier.toggleVideo()),
            onSwitchCamera: () => unawaited(notifier.switchCamera()),
            onLeave: () => unawaited(notifier.leaveRoom()),
          ),
          _ => _SetupView(
            roomController: _roomController,
            isJoining: state.isJoining,
            status: state.status,
            onJoin: () => unawaited(notifier.joinRoom(_roomController.text)),
          ),
        },
      ),
    );
  }
}

class const _SetupView({
  required final TextEditingController roomController,
  required final bool isJoining,
  required final LiveKitRoomStatus? status,
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
          decoration: InputDecoration(
            labelText: context.l10n.liveKitRoomNameLabel,
            hintText: context.l10n.liveKitRoomNameHint,
            border: const OutlineInputBorder(),
          ),
        ),
        if (status case final status?)
          Text(
            _describeStatus(context.l10n, status),
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
          label: Text(
            isJoining
                ? context.l10n.liveKitJoiningButton
                : context.l10n.liveKitJoinRoomButton,
          ),
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
                context.l10n.liveKitWaitingForRemoteParticipant,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                context.l10n.liveKitRoomInfo(roomName, localIdentity),
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
                tooltip: isAudioMuted
                    ? context.l10n.liveKitUnmuteMicrophoneTooltip
                    : context.l10n.liveKitMuteMicrophoneTooltip,
                icon: Icon(isAudioMuted ? Icons.mic_off : Icons.mic),
              ),
              IconButton.filledTonal(
                onPressed: onToggleVideo,
                tooltip: isVideoMuted
                    ? context.l10n.liveKitTurnCameraOnTooltip
                    : context.l10n.liveKitTurnCameraOffTooltip,
                icon: Icon(isVideoMuted ? Icons.videocam_off : Icons.videocam),
              ),
              IconButton.filledTonal(
                onPressed: isVideoMuted ? null : onSwitchCamera,
                tooltip: context.l10n.liveKitSwitchCameraTooltip,
                icon: const Icon(Icons.cameraswitch),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: onLeave,
                tooltip: context.l10n.liveKitLeaveRoomTooltip,
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
  required final LiveKitRoomStatus? status,
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
      if (status case final status?)
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
                _describeStatus(context.l10n, status),
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

String _describeStatus(AppLocalizations l10n, LiveKitRoomStatus status) {
  final detail = status.detail ?? '';
  return switch (status.type) {
    .roomNameRequired => l10n.liveKitRoomNameRequired,
    .permissionsRequired => l10n.liveKitPermissionsRequired,
    .disconnected => l10n.liveKitDisconnected(detail),
    .cameraUnavailable => l10n.liveKitCameraUnavailable(detail),
    .microphoneUnavailable => l10n.liveKitMicrophoneUnavailable(detail),
    .tokenFetchFailed => l10n.liveKitFailedToFetchToken(detail),
    .joinFailed => l10n.liveKitFailedToJoinRoom(detail),
    .toggleMicrophoneFailed => l10n.liveKitFailedToToggleMicrophone(detail),
    .toggleCameraFailed => l10n.liveKitFailedToToggleCamera(detail),
    .switchCameraFailed => l10n.liveKitFailedToSwitchCamera(detail),
  };
}
