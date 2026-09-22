import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/network/connectivity_cubit.dart';
import 'package:ibnzaidon/core/network/dio_factory.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/core/services/screen_security.dart';
import 'package:ibnzaidon/core/storage/app_flow_store.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';
import 'package:ibnzaidon/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Infrastructure: config, storage, networking, connectivity.
Future<void> registerCoreModule({
  required AppConfig config,
  required CrashReporter crashReporter,
}) async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<CrashReporter>(crashReporter)
    ..registerSingleton<KeyValueStore>(SharedPrefsKeyValueStore(prefs))
    ..registerSingleton<SecureStorage>(
      SecureStorage(
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
      ),
    )
    ..registerSingleton<AppFlowStore>(AppFlowStore(getIt()))
    ..registerSingleton<SettingsCubit>(SettingsCubit(getIt()))
    ..registerSingleton<LocaleCodeProvider>(getIt<SettingsCubit>())
    ..registerSingleton<SessionExpiryNotifier>(SessionExpiryNotifier())
    ..registerLazySingleton<Dio>(
      () => DioFactory.create(
        config: getIt(),
        storage: getIt(),
        locale: getIt(),
        sessionExpiry: getIt(),
      ),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<ApiGuard>(() => ApiGuard(getIt()))
    ..registerLazySingleton<JsonCache>(() => JsonCache(getIt(), getIt()))
    ..registerLazySingleton<ConnectivityCubit>(
      () => ConnectivityCubit(Connectivity()),
    )
    ..registerLazySingleton<ScreenSecurity>(
      () => Platform.isAndroid || Platform.isIOS
          ? PluginScreenSecurity(getIt())
          : const NoopScreenSecurity(),
    );
}
