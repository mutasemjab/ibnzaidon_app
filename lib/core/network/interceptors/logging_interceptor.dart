import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dev-only. Prints every request and response (method, path, status,
/// duration and the full JSON body) so a bad API response is easy to spot
/// during testing. Passwords and auth tokens are redacted; nothing else is
/// hidden.
class SafeLoggingInterceptor extends Interceptor {
  static const _startKey = 'startedAt';
  static const _maxBodyChars = 6000;
  static const _redactedKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'new_password',
    'new_password_confirmation',
    'token',
    'authorization',
  };

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    final query = options.queryParameters.isEmpty
        ? ''
        : '?${options.queryParameters}';
    debugPrint('[api] → ${options.method} ${options.path}$query');
    final body = options.data;
    if (body != null && body is! FormData) {
      _printBody('  body', body);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode);
    _printBody('  response', response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, error: err.type.name);
    if (err.response?.data != null) {
      _printBody('  response', err.response!.data);
    } else if (err.message != null) {
      debugPrint('  error: ${err.message}');
    }
    handler.next(err);
  }

  void _log(RequestOptions options, int? status, {String? error}) {
    final started = options.extra[_startKey] as int?;
    final elapsed = started == null
        ? ''
        : ' (${DateTime.now().millisecondsSinceEpoch - started}ms)';
    debugPrint(
      '[api] ← ${options.method} ${options.path} -> ${status ?? error}$elapsed',
    );
  }

  void _printBody(String label, Object? data) {
    if (data == null) return;
    final redacted = _redact(data);
    String text;
    try {
      text = redacted is String ? redacted : _encoder.convert(redacted);
    } on Object {
      text = redacted.toString();
    }
    if (text.isEmpty) return;
    if (text.length > _maxBodyChars) {
      text = '${text.substring(0, _maxBodyChars)}\n  …truncated';
    }
    debugPrint('$label: $text');
  }

  /// Deep-copies [data], replacing any value whose key looks like a
  /// password or auth token with `***`.
  Object? _redact(Object? data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key,
          _redactedKeys.contains(key.toString().toLowerCase())
              ? '***'
              : _redact(value),
        ),
      );
    }
    if (data is List) return data.map(_redact).toList();
    return data;
  }
}
