import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';

/// The single place `DioException` becomes a typed [Failure].
Failure mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(isTimeout: true);
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.transformTimeout:
      return const UnknownFailure();
    case DioExceptionType.unknown:
      return error.error is SocketException
          ? const NetworkFailure()
          : const UnknownFailure();
    case DioExceptionType.badResponse:
      return _fromResponse(error.response);
  }
}

Failure _fromResponse(Response<dynamic>? response) {
  final statusCode = response?.statusCode;
  final body = asMap(response?.data);
  final message = tryParseString(body?['message']);
  switch (statusCode) {
    case 401:
      return UnauthorizedFailure(message: message);
    case 403:
      return ForbiddenFailure(message: message);
    case 404:
      return NotFoundFailure(message: message);
    case 422:
      return ValidationFailure(
        fieldErrors: _parseFieldErrors(body?['errors']),
        message: message,
      );
    default:
      return ServerFailure(statusCode: statusCode, message: message);
  }
}

Map<String, List<String>> _parseFieldErrors(Object? raw) {
  final map = asMap(raw);
  if (map == null) return const {};
  return {
    for (final entry in map.entries)
      entry.key: entry.value is List
          ? [for (final item in entry.value as List) item.toString()]
          : [entry.value.toString()],
  };
}
