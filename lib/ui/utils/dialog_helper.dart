import 'package:material_ui/material_ui.dart';

/// Returns whether a dialog or another route is covering [context].
bool isDialogShowing(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent == false;
