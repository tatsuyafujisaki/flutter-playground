import 'package:fake_async/fake_async.dart';
import 'package:flutter_playground/data/utils/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('coalesces rapid calls into the latest callback', () {
      fakeAsync((async) {
        final debouncer = Debouncer(const Duration(milliseconds: 30));

        final calls = <int>[];
        debouncer
          ..run(() => calls.add(1))
          ..run(() => calls.add(2))
          ..run(() => calls.add(3));

        expect(calls, isEmpty);
        async.elapse(const Duration(milliseconds: 29));
        expect(calls, isEmpty);

        async.elapse(const Duration(milliseconds: 1));
        expect(calls, [3]);
        debouncer.dispose();
      });
    });

    test('dispose cancels any pending callback', () {
      fakeAsync((async) {
        final debouncer = Debouncer(const Duration(milliseconds: 30));
        var called = false;

        debouncer
          ..run(() => called = true)
          ..dispose();

        async.elapse(const Duration(milliseconds: 60));
        expect(called, isFalse);
      });
    });
  });
}
