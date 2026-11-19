import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'package:flutter_playground/data/enum/language.dart';
import 'package:flutter_playground/l10n/app_localizations.dart';

/// Convenience getters and locale helpers on [BuildContext].
extension BuildContextExtension on BuildContext {
  /// The localized strings for this context.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// The height of the current media query in logical pixels.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// The width of the current media query in logical pixels.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns whether the platform locale matches [language].
  bool isCurrentLocale(Language language) =>
      PlatformDispatcher.instance.locale.languageCode == language.code;
}
