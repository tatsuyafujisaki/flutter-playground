import 'package:flutter_playground/data/utils/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('coalesces rapid calls into the latest callback', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 30));
      addTearDown(debouncer.dispose);

      final calls = <int>[];
      debouncer
        ..run(() => calls.add(1))
        ..run(() => calls.add(2))
        ..run(() => calls.add(3));

      expect(calls, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(calls, [3]);
    });

    test('dispose cancels any pending callback', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 30));
      var called = false;

      debouncer
        ..run(() => called = true)
        ..dispose();

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(called, isFalse);
    });
  });
}
