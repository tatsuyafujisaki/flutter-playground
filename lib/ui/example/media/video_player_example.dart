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

typedef _VideoLogState = ({
  bool isBuffering,
  bool isCompleted,
  bool isInitialized,
  bool isLooping,
  bool isPlaying,
});

typedef _VideoUiState = ({
  bool isInitialized,
  bool isPlaying,
  bool hasError,
  double aspectRatio,
});

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final _controller = VideoPlayerController.networkUrl(
    .parse(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    ),
  );

  _VideoLogState? _lastLogState;
  _VideoUiState _uiState = (
    isInitialized: false,
    isPlaying: false,
    hasError: false,
    aspectRatio: 1,
  );
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdated);
    unawaited(_initializeController());
  }

  void _onControllerUpdated() {
    final value = _controller.value;
    final logState = (
      isBuffering: value.isBuffering,
      isCompleted: value.isCompleted,
      isInitialized: value.isInitialized,
      isLooping: value.isLooping,
      isPlaying: value.isPlaying,
    );
    if (logState != _lastLogState) {
      _lastLogState = logState;
      developer.log(
        '📹 Video state: buffering=${value.isBuffering}, '
        'completed=${value.isCompleted}, '
        'initialized=${value.isInitialized}, '
        'looping=${value.isLooping}, '
        'playing=${value.isPlaying}, '
        'position=${value.position}',
      );
    }

    final nextUiState = (
      isInitialized: value.isInitialized,
      isPlaying: value.isPlaying,
      hasError: value.hasError,
      aspectRatio: value.aspectRatio,
    );
    if (mounted && nextUiState != _uiState) {
      setState(() {
        _uiState = nextUiState;
        if (value.hasError) {
          _errorMessage ??= value.errorDescription ?? 'Failed to load video.';
        }
      });
    }
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      if (!mounted) {
        return;
      }
      await _controller.setLooping(true);
      if (!mounted) {
        return;
      }
      await _controller.play();
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to initialize video player',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = 'Failed to load video: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: switch (_errorMessage) {
          final message? => Padding(
            padding: const .all(16),
            child: Column(
              mainAxisSize: .min,
              spacing: 8,
              children: [
                const Icon(Icons.error_outline, size: 48),
                Text(message, textAlign: .center),
              ],
            ),
          ),
          null when _uiState.isInitialized => AspectRatio(
            aspectRatio: _uiState.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          null => const CircularProgressIndicator(),
        },
      ),
    ),
    floatingActionButton: _uiState.isInitialized && _errorMessage == null
        ? FloatingActionButton(
            onPressed: () {
              unawaited(
                _uiState.isPlaying ? _controller.pause() : _controller.play(),
              );
            },
            child: Icon(_uiState.isPlaying ? Icons.pause : Icons.play_arrow),
          )
        : null,
  );

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    unawaited(_controller.dispose());
    super.dispose();
  }
}
