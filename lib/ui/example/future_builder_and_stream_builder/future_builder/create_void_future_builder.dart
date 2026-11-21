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
    if (snapshot.connectionState == .done) {
      return onData();
    }
    if (snapshot.hasError) {
      developer.log(snapshot.error.toString());
      developer.log(snapshot.stackTrace.toString());
      return onError?.call() ?? const Center(child: Icon(Icons.error));
    }
    return onElse?.call() ?? const Center(child: CircularProgressIndicator());
  },
);
