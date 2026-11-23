import 'package:flutter_playground/ui/extension/async_snapshot_extension.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a [StreamBuilder] for a non-nullable [stream] that handles data,
/// error, and loading states.
StreamBuilder<T> createStreamBuilder<T extends Object>({
  required Widget Function(T) onData,
  Stream<T>? stream,
  Widget Function()? onError,
  Widget Function()? onElse,
}) => StreamBuilder<T>(
  stream: stream,
  builder: (context, snapshot) => snapshot.buildWidget(
    onData: onData,
    errorLogMessage: 'StreamBuilder error',
    onError: onError,
    onElse: onElse,
  ),
);
