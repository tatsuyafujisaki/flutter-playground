import 'dart:developer' as developer;

import 'package:material_ui/material_ui.dart';

/// Creates a [FutureBuilder] for a void [future] with fallback widgets.
FutureBuilder<void> createVoidFutureBuilder({
  required Widget Function() onData,
  Future<void>? future,
  Widget Function()? onError,
  Widget Function()? onElse,
}) => FutureBuilder<void>(
  future: future,
  builder: (context, snapshot) {
    switch (snapshot) {
      case AsyncSnapshot(:final error?, :final stackTrace):
        developer.log(
          'FutureBuilder error',
          error: error,
          stackTrace: stackTrace,
        );
        return onError?.call() ?? const Center(child: Icon(Icons.error));
      case AsyncSnapshot(connectionState: .done):
        return onData();
      case AsyncSnapshot():
        return onElse?.call() ??
            const Center(child: CircularProgressIndicator());
    }
  },
);
