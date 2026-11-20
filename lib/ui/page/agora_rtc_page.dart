import 'dart:async';
import 'dart:developer' as developer;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// A demo page for real-time audio and video calling using `agora_rtc_engine`.
class AgoraRtcPage extends StatefulWidget {
  /// Creates an [AgoraRtcPage].
  const new({super.key});

  @override
  State<AgoraRtcPage> createState() => _AgoraRtcPageState();
}

class _AgoraRtcPageState extends State<AgoraRtcPage> {
  static const _defaultAppId = String.fromEnvironment('AGORA_APP_ID');
  static const _defaultToken = String.fromEnvironment('AGORA_TOKEN');
  static const _defaultChannelName = String.fromEnvironment(
    'AGORA_CHANNEL_NAME',
    defaultValue: 'test',
  );

  late final TextEditingController _appIdController;
  late final TextEditingController _channelController;
  late final TextEditingController _tokenController;

  RtcEngine? _engine;
  RtcEngineEventHandler? _eventHandler;

  bool _isJoining = false;
  bool _isJoined = false;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  int? _localUid;
  final Set<int> _remoteUids = {};
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _appIdController = TextEditingController(text: _defaultAppId);
    _channelController = TextEditingController(text: _defaultChannelName);
    _tokenController = TextEditingController(text: _defaultToken);
  }

  @override
  void dispose() {
    unawaited(_releaseEngine());
    _appIdController.dispose();
    _channelController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) {
      return true;
    }
    final statuses = await [Permission.camera, Permission.microphone].request();
    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    return cameraGranted && micGranted;
  }

  Future<void> _joinChannel() async {
    final appId = _appIdController.text.trim();
    final channelId = _channelController.text.trim();
    final token = _tokenController.text.trim();

    if (appId.isEmpty) {
      setState(() => _statusMessage = 'Please enter an Agora App ID.');
      return;
    }
    if (channelId.isEmpty) {
      setState(() => _statusMessage = 'Please enter a channel name.');
      return;
    }

    setState(() {
      _isJoining = true;
      _statusMessage = null;
    });

    try {
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isJoining = false;
          _statusMessage =
              'Camera and microphone permissions are required to join a call.';
        });
        return;
      }

      await _releaseEngine();

      final engine = createAgoraRtcEngine();
      await engine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      final eventHandler = RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          developer.log(
            'Joined channel ${connection.channelId} as uid '
            '${connection.localUid}',
          );
          if (!mounted) {
            return;
          }
          setState(() {
            _isJoining = false;
            _isJoined = true;
            _localUid = connection.localUid;
            _statusMessage = null;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          developer.log('Remote user $remoteUid joined');
          if (!mounted) {
            return;
          }
          setState(() => _remoteUids.add(remoteUid));
        },
        onUserOffline: (connection, remoteUid, reason) {
          developer.log('Remote user $remoteUid left ($reason)');
          if (!mounted) {
            return;
          }
          setState(() => _remoteUids.remove(remoteUid));
        },
        onLeaveChannel: (connection, stats) {
          developer.log('Left channel ${connection.channelId}');
          if (!mounted) {
            return;
          }
          setState(() {
            _isJoined = false;
            _isJoining = false;
            _localUid = null;
            _remoteUids.clear();
          });
        },
        onError: (err, msg) {
          developer.log('Agora error: $err ($msg)');
          if (!mounted) {
            return;
          }
          setState(() {
            _isJoining = false;
            _statusMessage =
                'Agora error: ${err.name}'
                '${msg.isNotEmpty ? ' ($msg)' : ''}';
          });
        },
      );

      engine.registerEventHandler(eventHandler);
      _engine = engine;
      _eventHandler = eventHandler;

      await engine.enableVideo();
      await engine.startPreview();
      await engine.joinChannel(
        token: token,
        channelId: channelId,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to join Agora channel',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseEngine();
      if (!mounted) {
        return;
      }
      setState(() {
        _isJoining = false;
        _isJoined = false;
        _statusMessage = 'Failed to join channel: $error';
      });
    }
  }

  Future<void> _leaveChannel() async {
    await _releaseEngine();
    if (!mounted) {
      return;
    }
    setState(() {
      _isJoined = false;
      _isJoining = false;
      _isAudioMuted = false;
      _isVideoMuted = false;
      _localUid = null;
      _remoteUids.clear();
    });
  }

  Future<void> _releaseEngine() async {
    final engine = _engine;
    final eventHandler = _eventHandler;
    _engine = null;
    _eventHandler = null;
    if (engine == null) {
      return;
    }
    try {
      if (eventHandler != null) {
        engine.unregisterEventHandler(eventHandler);
      }
      await engine.leaveChannel();
      await engine.release();
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to release Agora engine',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _toggleAudio() async {
    final engine = _engine;
    if (engine == null) {
      return;
    }
    final nextMuted = !_isAudioMuted;
    await engine.muteLocalAudioStream(nextMuted);
    if (!mounted) {
      return;
    }
    setState(() => _isAudioMuted = nextMuted);
  }

  Future<void> _toggleVideo() async {
    final engine = _engine;
    if (engine == null) {
      return;
    }
    final nextMuted = !_isVideoMuted;
    await engine.muteLocalVideoStream(nextMuted);
    if (!mounted) {
      return;
    }
    setState(() => _isVideoMuted = nextMuted);
  }

  Future<void> _switchCamera() async {
    await _engine?.switchCamera();
  }

  Widget _buildSetupView() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        TextField(
          controller: _appIdController,
          enabled: !_isJoining,
          decoration: const InputDecoration(
            labelText: 'App ID',
            hintText: 'Enter your Agora App ID',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: _channelController,
          enabled: !_isJoining,
          decoration: const InputDecoration(
            labelText: 'Channel Name',
            hintText: 'e.g. test',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: _tokenController,
          enabled: !_isJoining,
          decoration: const InputDecoration(
            labelText: 'Token (optional)',
            hintText: 'Leave empty if testing without token auth',
            border: OutlineInputBorder(),
          ),
        ),
        if (_statusMessage case final message?)
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        FilledButton.icon(
          onPressed: _isJoining ? null : _joinChannel,
          icon: _isJoining
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.video_call),
          label: Text(_isJoining ? 'Joining...' : 'Join Channel'),
        ),
      ],
    ),
  );

  Widget _buildRemoteVideo(RtcEngine engine) {
    final channelId = _channelController.text.trim();
    if (_remoteUids.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Icon(Icons.people_outline, size: 48),
            Text(
              'Waiting for remote user...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Channel: $channelId (Local UID: ${_localUid ?? '-'})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (_remoteUids.length == 1) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: _remoteUids.first),
          connection: RtcConnection(channelId: channelId),
        ),
      );
    }

    final remoteUidList = _remoteUids.toList();
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: remoteUidList.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(uid: remoteUidList[index]),
            connection: RtcConnection(channelId: channelId),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalPreview(RtcEngine engine) => SizedBox(
    width: 120,
    height: 160,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: Colors.black87,
        child: _isVideoMuted
            ? const Center(child: Icon(Icons.videocam_off, color: Colors.white))
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
    ),
  );

  Widget _buildCallControls() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filledTonal(
            onPressed: _toggleAudio,
            tooltip: _isAudioMuted ? 'Unmute microphone' : 'Mute microphone',
            icon: Icon(_isAudioMuted ? Icons.mic_off : Icons.mic),
          ),
          IconButton.filledTonal(
            onPressed: _toggleVideo,
            tooltip: _isVideoMuted ? 'Turn camera on' : 'Turn camera off',
            icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam),
          ),
          IconButton.filledTonal(
            onPressed: _switchCamera,
            tooltip: 'Switch camera',
            icon: const Icon(Icons.cameraswitch),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: _leaveChannel,
            tooltip: 'Leave channel',
            icon: const Icon(Icons.call_end),
          ),
        ],
      ),
    ),
  );

  Widget _buildCallView(RtcEngine engine) => Stack(
    children: [
      Positioned.fill(child: _buildRemoteVideo(engine)),
      Positioned(top: 16, right: 16, child: _buildLocalPreview(engine)),
      if (_statusMessage case final message?)
        Positioned(
          top: 16,
          left: 16,
          right: 152,
          child: Material(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      Align(alignment: Alignment.bottomCenter, child: _buildCallControls()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    return Scaffold(
      appBar: AppBar(title: const Text('Agora RTC')),
      body: SafeArea(
        child: _isJoined && engine != null
            ? _buildCallView(engine)
            : _buildSetupView(),
      ),
    );
  }
}
