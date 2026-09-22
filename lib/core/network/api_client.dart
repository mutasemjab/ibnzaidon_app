import 'package:dio/dio.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/network/interceptors/unauthorized_interceptor.dart';

/// Thin typed wrapper over Dio returning [ApiEnvelope]s. Datasources use this
/// — never Dio directly.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? query,
    bool optionalAuth = false,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: _clean(query),
      options: Options(extra: {if (optionalAuth) skipSessionExpiryKey: true}),
    );
    return _parse(response);
  }

  Future<ApiEnvelope> post(
    String path, {
    Object? body,
    bool skipSessionExpiry = false,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: body,
      options: Options(extra: {skipSessionExpiryKey: skipSessionExpiry}),
    );
    return _parse(response);
  }

  /// Like [post] but also exposes the HTTP status (exam start returns 201 for
  /// a new attempt and 200 when resuming one).
  Future<({ApiEnvelope envelope, int? statusCode})> postRaw(
    String path, {
    Object? body,
  }) async {
    final response = await _dio.post<Object?>(path, data: body);
    return (envelope: _parse(response), statusCode: response.statusCode);
  }

  Future<ApiEnvelope> put(String path, {Object? body}) async =>
      _parse(await _dio.put<Object?>(path, data: body));

  Future<ApiEnvelope> delete(String path) async =>
      _parse(await _dio.delete<Object?>(path));

  /// Laravel cannot read multipart bodies on PUT, so the file upload uses
  /// POST with `_method=PUT` spoofing.
  Future<ApiEnvelope> putMultipart(String path, FormData form) async {
    form.fields.add(const MapEntry('_method', 'PUT'));
    return _parse(await _dio.post<Object?>(path, data: form));
  }

  Future<void> download(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    await Dio().download(url, savePath, onReceiveProgress: onProgress);
  }

  ApiEnvelope _parse(Response<Object?> response) {
    final envelope = ApiEnvelope.fromJson(response.data);
    if (!envelope.status) {
      throw ApiBusinessException(
        ServerFailure(
          statusCode: response.statusCode,
          message: envelope.message,
        ),
      );
    }
    return envelope;
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    return Map.of(query)..removeWhere(
      (_, value) => value == null || (value is String && value.isEmpty),
    );
  }
}
