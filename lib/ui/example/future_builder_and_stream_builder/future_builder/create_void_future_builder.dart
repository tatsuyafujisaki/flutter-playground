import 'package:flutter_playground/ui/extension/async_snapshot_extension.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a [FutureBuilder] for a void [future] with fallback widgets.
FutureBuilder<void> createVoidFutureBuilder({
  required Widget Function() onData,
  Future<void>? future,
  Widget Function()? onError,
  Widget Function()? onElse,
}) => FutureBuilder<void>(
  future: future,
  builder: (context, snapshot) => snapshot.buildVoidWidget(
    onData: onData,
    errorLogMessage: 'FutureBuilder error',
    onError: onError,
    onElse: onElse,
  ),
);
