import 'package:flutter_playground/ui/extension/async_snapshot_extension.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a [FutureBuilder] for a non-nullable [future] with fallback widgets.
FutureBuilder<T> createNonVoidFutureBuilder<T extends Object>({
  required Widget Function(T) onData,
  Future<T>? future,
  Widget Function()? onError,
  Widget Function()? onElse,
}) => FutureBuilder<T>(
  future: future,
  builder: (context, snapshot) => snapshot.buildWidget(
    onData: onData,
    errorLogMessage: 'FutureBuilder error',
    onError: onError,
    onElse: onElse,
  ),
);
