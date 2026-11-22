import 'dart:async';

Future<void> main() async {
  final streamController = StreamController<void>();
  final subscription = streamController.stream.listen((_) {});

  try {
    // Attempting to add a second listener to a non-broadcast StreamController
    // throws StateError (Bad state: Stream has already been listened to.).
    streamController.stream.listen((_) {});
  } finally {
    await subscription.cancel();
    await streamController.close();
  }
}
