import 'dart:async';

import 'package:dio/dio.dart';

/// One automatic retry for idempotent GETs on transport errors, with
/// exponential backoff.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 1,
    this.baseDelay = const Duration(milliseconds: 600),
  });

  static const _retryCountKey = 'retryCount';

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }
    await Future<void>.delayed(baseDelay * (1 << attempt));
    err.requestOptions.extra[_retryCountKey] = attempt + 1;
    try {
      final response = await _dio.fetch<Object?>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }
}
