import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';

/// Backend messages are Arabic-only, so only 403/422 business rules may
/// fall back to the server text; everything else is localized here.
extension FailureMessage on Failure {
  String localized(AppLocalizations l10n) => switch (this) {
    NetworkFailure(isTimeout: true) => l10n.errorTimeout,
    NetworkFailure() => l10n.errorNoInternet,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    final ForbiddenFailure f => _serverOr(f.message, l10n.errorForbidden),
    final ValidationFailure f => _serverOr(f.firstError, l10n.errorValidation),
    NotFoundFailure() => l10n.errorNotFound,
    ServerFailure() => l10n.errorServer,
    UnknownFailure() => l10n.errorUnknown,
  };

  String _serverOr(String? serverMessage, String fallback) =>
      serverMessage == null || serverMessage.isEmpty ? fallback : serverMessage;
}
