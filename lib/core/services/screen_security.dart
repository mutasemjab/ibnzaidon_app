import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:screen_protector/screen_protector.dart';

/// Blocks screenshots/recording on exam and paid-video screens
/// (`FLAG_SECURE` on Android, screenshot prevention on iOS).
abstract interface class ScreenSecurity {
  Future<void> enable();
  Future<void> disable();
}

final class PluginScreenSecurity implements ScreenSecurity {
  const PluginScreenSecurity(this._config);

  final AppConfig _config;

  @override
  Future<void> enable() async {
    if (!_config.secureScreensEnabled) return;
    try {
      await ScreenProtector.preventScreenshotOn();
    } on Object {
      // Unsupported platform (tests, desktop): nothing to protect.
    }
  }

  @override
  Future<void> disable() async {
    if (!_config.secureScreensEnabled) return;
    try {
      await ScreenProtector.preventScreenshotOff();
    } on Object {
      // See enable().
    }
  }
}

final class NoopScreenSecurity implements ScreenSecurity {
  const NoopScreenSecurity();

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}
