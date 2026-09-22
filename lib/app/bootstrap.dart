import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ibnzaidon/app/app.dart';
import 'package:ibnzaidon/app/di/core_module.dart';
import 'package:ibnzaidon/app/di/features_module.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/services/firebase_crash_reporter.dart';
import 'package:ibnzaidon/features/app_settings/presentation/bloc/app_settings_cubit.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/settings/presentation/bloc/settings_cubit.dart';

/// Shared entry for every flavor. Startup never depends on a single
/// endpoint: Firebase, session restore and app-settings all fail soft.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final crashReporter = await _initFirebase();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashReporter.recordError(
      details.exception,
      details.stack,
      reason: 'flutter',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    crashReporter.recordError(error, stack, reason: 'platform');
    return true;
  };

  await registerCoreModule(config: config, crashReporter: crashReporter);
  registerFeatureModules();

  LocaleChanges.stream = getIt<SettingsCubit>().languageChanges;
  getIt<AuthBloc>().add(const AuthStarted());
  unawaited(getIt<AppSettingsCubit>().load());

  runApp(const IbnZaidonApp());
}

Future<CrashReporter> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    return FirebaseCrashReporter(FirebaseCrashlytics.instance);
  } on Object {
    // No Firebase config for this platform/flavor: run without it.
    return const NoopCrashReporter();
  }
}
