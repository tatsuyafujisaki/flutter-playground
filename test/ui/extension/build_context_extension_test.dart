import 'package:flutter_playground/l10n/app_localizations.dart';
import 'package:flutter_playground/ui/extension/build_context_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('BuildContextExtension', () {
    testWidgets('exposes l10n, screen dimensions, and locale matching', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedContext.l10n.forceUpdateDialogUpdateButton, 'アップデート');
      expect(capturedContext.screenWidth, 800);
      expect(capturedContext.screenHeight, 600);
      expect(capturedContext.isCurrentLocale(.japanese), isTrue);
      expect(capturedContext.isCurrentLocale(.english), isFalse);
    });
  });
}
