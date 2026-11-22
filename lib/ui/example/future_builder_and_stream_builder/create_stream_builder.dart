import 'dart:developer' as developer;

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
  builder: (context, snapshot) {
    switch (snapshot) {
      case AsyncSnapshot(:final data?):
        return onData(data);
      case AsyncSnapshot(:final error?, :final stackTrace):
        developer.log(
          'StreamBuilder error',
          error: error,
          stackTrace: stackTrace,
        );
        return onError?.call() ?? const Center(child: Icon(Icons.error));
      case AsyncSnapshot():
        return onElse?.call() ??
            const Center(child: CircularProgressIndicator());
    }
  },
);
