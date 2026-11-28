import 'package:flutter_playground/data/enum/language.dart';
import 'package:flutter_playground/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Convenience getters and locale helpers on [BuildContext].
extension BuildContextExtension on BuildContext {
  /// The localized strings for this context.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The height of the current media query in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// The width of the current media query in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Returns whether the current locale matches [language].
  bool isCurrentLocale(Language language) =>
      Localizations.localeOf(this).languageCode == language.code;
}
