import 'package:flutter_playground/ui/utils/dialog_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('isDialogShowing', () {
    testWidgets('returns false normally and true while a dialog is covering', (
      tester,
    ) async {
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              pageContext = context;
              return const Scaffold();
            },
          ),
        ),
      );

      expect(isDialogShowing(pageContext), isFalse);

      showDialog<void>(
        context: pageContext,
        builder: (_) => const AlertDialog(title: Text('Dialog')),
      ).ignore();
      await tester.pumpAndSettle();

      expect(isDialogShowing(pageContext), isTrue);

      Navigator.pop(pageContext);
      await tester.pumpAndSettle();

      expect(isDialogShowing(pageContext), isFalse);
    });
  });
}
