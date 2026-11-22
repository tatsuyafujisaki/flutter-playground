import 'dart:async';

import 'package:flutter_playground/extension/stream_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamExtension', () {
    test(
      'handle intercepts data, error, and done events without altering stream',
      () async {
        final handledData = <int>[];
        final handledErrors = <Object>[];
        var handledDone = false;

        final controller = StreamController<int>();
        final forwardedData = <int>[];
        final forwardedErrors = <Object>[];
        final doneCompleter = Completer<void>();

        controller.stream
            .handle(
              handleData: handledData.add,
              handleError: (error, _) => handledErrors.add(error),
              handleDone: () => handledDone = true,
            )
            .listen(
              forwardedData.add,
              onError: (Object error, StackTrace _) =>
                  forwardedErrors.add(error),
              onDone: doneCompleter.complete,
            );

        controller
          ..add(1)
          ..addError(StateError('boom'))
          ..add(2);
        await controller.close();
        await doneCompleter.future;

        expect(handledData, [1, 2]);
        expect(forwardedData, [1, 2]);
        expect(handledErrors, hasLength(1));
        expect(forwardedErrors, hasLength(1));
        expect(handledDone, isTrue);
      },
    );

    test('log forwards all stream events unchanged', () async {
      final values = await Stream.fromIterable([10, 20, 30]).log().toList();
      expect(values, [10, 20, 30]);
    });
  });
}
