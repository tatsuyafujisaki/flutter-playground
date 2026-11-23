import 'dart:async';
import 'dart:io';

/// A container that manages and disposes multiple stream subscriptions.
class CompositeSubscription() {
  /// Creates a [CompositeSubscription].
  this;

  final _subscriptions = <StreamSubscription<Object?>>{};
  var _isDisposed = false;

  /// Whether this subscription container has been disposed.
  bool get isDisposed => _isDisposed;

  /// Adds [subscription] to this container.
  ///
  /// Throws a [StateError] if this container has already been disposed.
  void add(StreamSubscription<Object?> subscription) {
    if (_isDisposed) {
      throw StateError('CompositeSubscription is already disposed.');
    }
    _subscriptions.add(subscription);
  }

  /// Cancels all managed subscriptions and marks this container as disposed.
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    final subscriptions = _subscriptions.toList();
    _subscriptions.clear();
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
  }
}

Future<void> main() async {
  final composite = CompositeSubscription();
  final controller = StreamController<String>.broadcast();
  composite.add(controller.stream.listen(stdout.writeln));
  controller.add('🍎');
  await composite.dispose();
  await controller.close();
}
