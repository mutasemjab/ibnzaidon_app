import 'package:dio/dio.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';

/// Adds `Authorization`, `Accept-Language` and `Accept` to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._locale);

  final SecureStorage _storage;
  final LocaleCodeProvider _locale;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = _locale.languageCode;
    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
