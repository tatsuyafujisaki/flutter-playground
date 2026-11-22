import 'dart:developer' as developer;

import 'package:material_ui/material_ui.dart';

/// Creates a [FutureBuilder] for a non-void [future] with fallback widgets.
FutureBuilder<T> createNonVoidFutureBuilder<T>({
  required Widget Function(T) onData,
  Future<T>? future,
  Widget Function()? onError,
  Widget Function()? onElse,
}) => FutureBuilder<T>(
  future: future,
  builder: (context, snapshot) {
    switch (snapshot) {
      case AsyncSnapshot(:final data?):
        return onData(data);
      case AsyncSnapshot(:final error?, :final stackTrace):
        developer.log(
          'FutureBuilder error',
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
