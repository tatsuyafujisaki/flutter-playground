import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

/// Previews a [VideoPlayer] widget with play and pause controls.
@Preview(group: 'Packages', name: 'Video Player')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final _controller = VideoPlayerController.networkUrl(
    .parse(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_logVideoState);
    unawaited(_initializeController());
  }

  void _logVideoState() {
    final value = _controller.value;
    developer.log('📹isBuffering: ${value.isBuffering}');
    developer.log('📹isCompleted: ${value.isCompleted}');
    developer.log('📹isInitialized: ${value.isInitialized}');
    developer.log('📹isLooping: ${value.isLooping}');
    developer.log('📹isPlaying: ${value.isPlaying}');
    developer.log('📹position: ${value.position}');
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    if (!mounted) {
      return;
    }
    await _controller.setLooping(true);
    if (!mounted) {
      return;
    }
    await _controller.play();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _controller,
    builder: (context, value, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: value.isInitialized
              ? AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(value.isPlaying ? _controller.pause() : _controller.play());
        },
        child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    ),
  );

  @override
  void dispose() {
    _controller.removeListener(_logVideoState);
    unawaited(_controller.dispose());
    super.dispose();
  }
}
