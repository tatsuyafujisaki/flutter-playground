import 'package:flutter_playground/ui/extension/async_snapshot_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AsyncSnapshotExtension', () {
    testWidgets('buildWidget renders data, error, and loading states', (
      tester,
    ) async {
      const dataSnapshot = AsyncSnapshot<String>.withData(.done, '🍎');
      await tester.pumpWidget(
        MaterialApp(
          home: dataSnapshot.buildWidget(
            onData: Text.new,
            errorLogMessage: 'test error',
          ),
        ),
      );
      expect(find.text('🍎'), findsOneWidget);

      final errorSnapshot = AsyncSnapshot<String>.withError(
        .done,
        Exception('boom'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: errorSnapshot.buildWidget(
            onData: Text.new,
            errorLogMessage: 'test error',
          ),
        ),
      );
      expect(find.byIcon(Icons.error), findsOneWidget);

      const loadingSnapshot = AsyncSnapshot<String>.waiting();
      await tester.pumpWidget(
        MaterialApp(
          home: loadingSnapshot.buildWidget(
            onData: Text.new,
            errorLogMessage: 'test error',
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('buildVoidWidget renders done, error, and loading states', (
      tester,
    ) async {
      const doneSnapshot = AsyncSnapshot<void>.nothing();
      await tester.pumpWidget(
        MaterialApp(
          home: const AsyncSnapshot<void>.withData(.done, null).buildVoidWidget(
            onData: () => const Text('done'),
            errorLogMessage: 'void error',
          ),
        ),
      );
      expect(find.text('done'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: doneSnapshot.buildVoidWidget(
            onData: () => const Text('done'),
            errorLogMessage: 'void error',
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
