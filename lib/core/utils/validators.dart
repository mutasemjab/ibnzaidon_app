import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';

/// Client-side validation. Messages are localized; server 422 errors are
/// still shown inline on top of these.
abstract final class Validators {
  static const minPasswordLength = 8;

  /// Tolerant phone check: optional `+`, digits/spaces/dashes, 8-15 digits.
  static final _phonePattern = RegExp(r'^\+?[0-9\s-]{8,18}$');
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? Function(String?) required(AppLocalizations l10n) =>
      (value) => (value == null || value.trim().isEmpty)
      ? l10n.validationRequired
      : null;

  static String? Function(String?) phone(AppLocalizations l10n) => (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.validationRequired;
    return _phonePattern.hasMatch(text) ? null : l10n.validationPhone;
  };

  static String? Function(String?) optionalEmail(AppLocalizations l10n) =>
      (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return null;
        return _emailPattern.hasMatch(text) ? null : l10n.validationEmail;
      };

  static String? Function(String?) password(AppLocalizations l10n) => (value) {
    if (value == null || value.isEmpty) return l10n.validationRequired;
    return value.length < minPasswordLength
        ? l10n.validationPasswordShort
        : null;
  };

  static String? Function(String?) confirmPassword(
    AppLocalizations l10n,
    String Function() original,
  ) => (value) {
    if (value == null || value.isEmpty) return l10n.validationRequired;
    return value == original() ? null : l10n.validationPasswordMismatch;
  };

  /// Removes spaces/dashes so the backend gets a clean number.
  static String normalizePhone(String value) =>
      value.replaceAll(RegExp(r'[\s-]'), '');
}
