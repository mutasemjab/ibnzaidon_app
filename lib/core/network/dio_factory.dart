import 'package:dio/dio.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/network/interceptors/auth_interceptor.dart';
import 'package:ibnzaidon/core/network/interceptors/logging_interceptor.dart';
import 'package:ibnzaidon/core/network/interceptors/retry_interceptor.dart';
import 'package:ibnzaidon/core/network/interceptors/unauthorized_interceptor.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';

abstract final class DioFactory {
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);

  static Dio create({
    required AppConfig config,
    required SecureStorage storage,
    required LocaleCodeProvider locale,
    required SessionExpiryNotifier sessionExpiry,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: receiveTimeout,
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(storage, locale),
      RetryInterceptor(dio),
      UnauthorizedInterceptor(storage, sessionExpiry),
      if (config.loggingEnabled) SafeLoggingInterceptor(),
    ]);
    return dio;
  }
}
