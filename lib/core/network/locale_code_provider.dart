/// Lets the network layer read the active language without depending on the
/// settings feature.
abstract interface class LocaleCodeProvider {
  String get languageCode;
}

/// Emits the new language code whenever the user switches language. Screen
/// blocs listen so visible content is refetched in the new language (server
/// content is localized through `Accept-Language`). Wired in `bootstrap`.
abstract final class LocaleChanges {
  static Stream<String> stream = const Stream.empty();
}
