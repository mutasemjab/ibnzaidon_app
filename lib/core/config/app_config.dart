import 'package:ibnzaidon/core/config/feature_flags.dart';

enum Flavor { dev, prod }

/// Typed, immutable runtime configuration. Values are overridable through
/// `--dart-define` so CI can point a build at any environment.
final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    this.applePurchaseProductPrefix = 'com.IbnZaidon.school.course.v2.',
    this.secureScreensEnabled = true,
    this.loggingEnabled = true,
    this.featureFlags = const FeatureFlags(),
  });

  factory AppConfig.dev() => const AppConfig(
    flavor: Flavor.dev,
    appName: 'Ibn Zaidon (Dev)',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev.ibnzaidon.com',
    ),
    secureScreensEnabled: bool.fromEnvironment('SECURE_SCREENS'),
    loggingEnabled: bool.fromEnvironment('API_LOGGING', defaultValue: true),
    featureFlags: _flagsFromEnvironment,
  );

  factory AppConfig.prod() => const AppConfig(
    flavor: Flavor.prod,
    appName: 'Ibn Zaidon',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://ibnzaidon.com',
    ),
    secureScreensEnabled: bool.fromEnvironment(
      'SECURE_SCREENS',
      defaultValue: true,
    ),
    // On by default so `main_prod` (the plain `flutter run` / `main.dart`
    // entry point) prints API responses too. Turn off for a real store
    // build with `--dart-define=API_LOGGING=false`.
    loggingEnabled: bool.fromEnvironment('API_LOGGING', defaultValue: true),
    featureFlags: _flagsFromEnvironment,
  );

  static const _flagsFromEnvironment = FeatureFlags(
    announcements: bool.fromEnvironment('FF_ANNOUNCEMENTS'),
    conduct: bool.fromEnvironment('FF_CONDUCT'),
    planners: bool.fromEnvironment('FF_PLANNERS'),
    schedules: bool.fromEnvironment('FF_SCHEDULES'),
    siblingSwitch: bool.fromEnvironment('FF_SIBLINGS'),
  );

  final Flavor flavor;
  final String appName;
  final String baseUrl;
  final String applePurchaseProductPrefix;
  final bool secureScreensEnabled;
  final bool loggingEnabled;
  final FeatureFlags featureFlags;

  String get apiBaseUrl => '$baseUrl/api/v1/student/';
  bool get isDev => flavor == Flavor.dev;

  String appleProductId(int courseId) => '$applePurchaseProductPrefix$courseId';
}
