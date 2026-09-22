import 'package:equatable/equatable.dart';

/// Typed failures. Domain and presentation only ever see these — never
/// `DioException`.
sealed class Failure extends Equatable {
  const Failure({this.message});

  /// Raw backend message (Arabic-only). Only surfaced for 403/422 business
  /// rules; everything else is mapped to localized strings.
  final String? message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({this.isTimeout = false});

  final bool isTimeout;

  @override
  List<Object?> get props => [isTimeout];
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message});
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({this.fieldErrors = const {}, super.message});

  final Map<String, List<String>> fieldErrors;

  String? firstErrorFor(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  String? get firstError {
    for (final errors in fieldErrors.values) {
      if (errors.isNotEmpty) return errors.first;
    }
    return message;
  }

  @override
  List<Object?> get props => [fieldErrors, message];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}

final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.message});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}
