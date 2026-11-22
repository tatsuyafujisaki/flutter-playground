import 'package:flutter_playground/data/utils/upgrade_utils.dart';
import 'package:flutter_playground/ui/extension/build_context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checks whether a force update is required and shows a blocking dialog if it
/// is.
Future<void> showForceUpdateDialogIfNeeded(
  NavigatorState navigatorState,
) async {
  final storeUri = await getForceUpdateStoreUri();
  if (storeUri == null || !navigatorState.mounted) {
    return;
  }

  await _showUpgradeDialog(navigatorState, storeUri);
}

Future<void> _showUpgradeDialog(NavigatorState navigatorState, Uri storeUri) =>
    showDialog<void>(
      context: navigatorState.context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = context.l10n;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.forceUpdateDialogTitle),
            content: Text(l10n.forceUpdateDialogBody),
            actions: [
              TextButton(
                onPressed: () =>
                    launchUrl(storeUri, mode: .externalApplication),
                child: Text(l10n.forceUpdateDialogUpdateButton),
              ),
            ],
          ),
        );
      },
    );
