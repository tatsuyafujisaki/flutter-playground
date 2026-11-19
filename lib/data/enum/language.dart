/// A supported language.
enum Language {
  /// English.
  english(code: 'en'),

  /// Japanese.
  japanese(code: 'ja');

  new({required this.code});

  /// The ISO 639-1 language code.
  final String code;
}
