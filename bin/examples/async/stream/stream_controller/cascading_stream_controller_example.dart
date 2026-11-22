import 'dart:async';
import 'dart:developer' as developer;

// This example is ...
//   - impractical and not worth reading for many people.
//   - for me to get used to some legacy code.
class _MyParentClass {
  final streamController = StreamController<String>.broadcast();

  void parentNotify() {
    streamController.add('parentNotify is called.');
  }

  Future<void> dispose() => streamController.close();
}

class _MyChildClass extends _MyParentClass {
  void childNotify() {
    streamController.add('childNotify is called.');
  }
}

Future<void> main() async {
  final myChildClass = _MyChildClass();
  final subscription = myChildClass.streamController.stream.listen(
    (event) => developer.log('onData: $event'),
  );

  try {
    myChildClass
      ..parentNotify()
      ..childNotify();
  } finally {
    await myChildClass.dispose();
    await subscription.cancel();
  }
}
