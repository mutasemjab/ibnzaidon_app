import 'package:ibnzaidon/core/config/feature_flags.dart';

/// Typed, immutable runtime configuration. Values are overridable through
/// `--dart-define` (rarely needed — the defaults point at the real API).
final class AppConfig {
  const AppConfig({
    required this.appName,
    required this.baseUrl,
    this.applePurchaseProductPrefix = 'com.IbnZaidon.school.course.v2.',
    this.secureScreensEnabled = true,
    this.loggingEnabled = true,
    this.featureFlags = const FeatureFlags(),
  });

  factory AppConfig.standard() => const AppConfig(
    appName: 'Ibn Zaidon',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://ibnzaidon.com',
    ),
    secureScreensEnabled: bool.fromEnvironment(
      'SECURE_SCREENS',
      defaultValue: true,
    ),
    // On by default: every API request/response is printed to the console
    // so problems are easy to spot. Turn off for a real store build with
    // `--dart-define=API_LOGGING=false`.
    loggingEnabled: bool.fromEnvironment('API_LOGGING', defaultValue: true),
    featureFlags: FeatureFlags(
      announcements: bool.fromEnvironment('FF_ANNOUNCEMENTS'),
      conduct: bool.fromEnvironment('FF_CONDUCT'),
      planners: bool.fromEnvironment('FF_PLANNERS'),
      schedules: bool.fromEnvironment('FF_SCHEDULES'),
      siblingSwitch: bool.fromEnvironment('FF_SIBLINGS'),
    ),
  );

  final String appName;
  final String baseUrl;
  final String applePurchaseProductPrefix;
  final bool secureScreensEnabled;
  final bool loggingEnabled;
  final FeatureFlags featureFlags;

  String get apiBaseUrl => '$baseUrl/api/v1/student/';

  String appleProductId(int courseId) => '$applePurchaseProductPrefix$courseId';
}
