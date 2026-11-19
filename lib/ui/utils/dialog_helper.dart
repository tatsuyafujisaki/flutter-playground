import 'package:flutter/widgets.dart';

/// Returns whether a dialog or another route is covering [context].
bool isDialogShowing(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent == false;
